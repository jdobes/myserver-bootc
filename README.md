# My server bootc image

Customized CentOS Stream 10 bootc image for my servers. It features:

- Extra packages installed
- amd64 and arm64 variants (to do)
- Automatic weekly image re-build using GitHub Actions (to do)

## Local build

    # Build OCI image (it is using sudo because image builder has to be executed in privileged container in the next step)
    $ sudo podman build --label=org.opencontainers.image.version=$(git rev-parse --short HEAD)-$(date "+%Y-%m-%d.%H%M%S") --squash -t localhost/myserver-bootc .

    # Build qcow2 image from OCI image
    $ mkdir output
    $ sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t \
      -v ./config.toml:/config.toml:ro \
      -v ./output:/output \
      -v /var/lib/containers/storage:/var/lib/containers/storage \
      quay.io/centos-bootc/bootc-image-builder:latest --type qcow2 --local localhost/myserver-bootc

## Local test

    # Running as a container
    $ sudo podman run --rm -it localhost/myserver-bootc bash

    # Running as a VM
    $ qemu-system-x86_64 \
      -M accel=kvm \
      -cpu host \
      -smp 2 \
      -m 4096 \
      -bios /usr/share/OVMF/OVMF_CODE.fd \
      -serial stdio \
      -snapshot output/qcow2/disk.qcow2

    # or on MacOS
    $ qemu-system-aarch64 \
      -M accel=hvf \
      -cpu host \
      -smp 2 \
      -m 4096 \
      -bios $(brew info qemu | grep /opt/homebrew/Cellar/qemu/ | awk '{print $1}')/share/qemu/edk2-aarch64-code.fd \
      -serial stdio \
      -machine virt \
      -snapshot output/qcow2/disk.qcow2
