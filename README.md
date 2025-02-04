# My server bootc image

Customized CentOS Stream 10 bootc image for my servers. It features:

- Extra packages installed
- amd64 and arm64 variants
- Automatic weekly image re-build using GitHub Actions (to do)

## How it works

1. Customize the OS in `Containerfile`
2. Build OCI image using `podman`
3. (If needed) Build the qcow2 image or ISO installer using `bootc-image-builder`

## Usage

There is a `Makefile` to make local building and testing easier:

    $ make help
    Usage:
      make
      all              clean and build OCI + qcow2 image (default)
      help             show help
      clean            clean build artifacts
      build-oci        build OCI image
      build-qcow       build qcow2 image
      run-container    run as a container
      run-vm           run as a virtual machine
