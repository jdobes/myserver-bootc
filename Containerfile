FROM quay.io/centos-bootc/centos-bootc:stream10

RUN dnf config-manager --set-enabled crb && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

RUN dnf -y install btop fastfetch git vim && \
    dnf clean all

# Disable auto updates
RUN systemctl mask bootc-fetch-apply-updates.timer

# Setting up permissions for rootless podman
RUN echo "net.ipv4.ip_unprivileged_port_start=53" >> /etc/sysctl.conf

# Setting up script to run on first boot when user exists
ADD custom-first-boot.sh      /usr/local/sbin
ADD custom-first-boot.service /usr/lib/systemd/system/
RUN systemctl enable custom-first-boot.service

RUN bootc container lint
