image_name := localhost/myserver
tag := $(shell date "+%Y%m%d")
platform := $(shell uname -sm)

.PHONY: all
all: clean build-oci build-qcow  ## clean and build OCI + qcow2 image (default)

.PHONY: help
help: ## show help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: clean
clean:  ## clean build artifacts
	sudo podman rmi -i $(image_name):$(tag) $(image_name):latest
	sudo rm -rf output

.PHONY: build-oci
build-oci:  ## build OCI image
	sudo podman build --label=org.opencontainers.image.version=$(tag) --squash -t $(image_name):$(tag) -t $(image_name):latest .

.PHONY: build-qcow
build-qcow:  ## build qcow2 image
	mkdir -p output
	sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t \
	  -v ./config.toml:/config.toml:ro \
	  -v ./output:/output \
	  -v /var/lib/containers/storage:/var/lib/containers/storage \
	  quay.io/centos-bootc/bootc-image-builder:latest --type qcow2 --local $(image_name):latest

.PHONY: run-container
run-container:  ## run as a container
	sudo podman run --rm -it $(image_name):latest bash

.PHONY: run-vm
run-vm:  ## run as a virtual machine
ifeq ($(platform),Linux x86_64)
	qemu-system-x86_64 \
	  -M accel=kvm \
	  -cpu host \
	  -smp 2 \
	  -m 4096 \
	  -bios /usr/share/OVMF/OVMF_CODE.fd \
	  -monitor stdio \
	  -vnc none \
	  -net nic \
	  -net user,hostfwd=tcp::2222-:22,hostfwd=tcp::5353-:53,hostfwd=tcp::8080-:80,hostfwd=tcp::8443-:443 \
	  output/qcow2/disk.qcow2
else ifeq ($(platform),Darwin arm64)
	qemu-system-aarch64 \
	  -M accel=hvf \
	  -cpu host \
	  -smp 2 \
	  -m 4096 \
	  -bios $(shell brew info qemu | grep /opt/homebrew/Cellar/qemu/ | awk '{print $$1}')/share/qemu/edk2-aarch64-code.fd \
	  -monitor stdio \
	  -vnc none \
	  -machine virt \
	  -net nic \
	  -net user,hostfwd=tcp::2222-:22,hostfwd=tcp::5353-:53,hostfwd=tcp::8080-:80,hostfwd=tcp::8443-:443 \
	  output/qcow2/disk.qcow2
else
	@echo "Unsupported platform"
endif
