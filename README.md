# My server bootc image

Customized CentOS Stream 10 bootc image for my servers. It features:

- Extra packages installed
- amd64 and arm64 variants
- Automatic weekly image re-build using GitHub Actions
- Simple Podman Quadlet GitOps

## How it works

1. Customize the OS in `Containerfile` and other files
2. Build OCI image using `podman`
3. (For the first time setup) Build the qcow2 image for VM or ISO installer using `bootc-image-builder`

## First-time setup

1. Configure source Quadlet git repository and subdirectory name:

       vim .config/systemd/user/quadlet-sync.service.d/env.conf

2. Enable the timer:

       systemctl --user enable --now quadlet-sync.timer

## Development

There is a `Makefile` to make local building and testing easier:

    $ make help
    Usage:
      make
      all              clean and build OCI + qcow2 image (default)
      help             show help
      clean            clean build artifacts
      build-oci        build OCI image
      build-qcow       build qcow2 image
      build-iso        build anaconda ISO
      run-container    run as a container
      run-vm           run as a virtual machine
