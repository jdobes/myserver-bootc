FROM quay.io/centos-bootc/centos-bootc:stream10

RUN dnf config-manager --set-enabled crb && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

RUN dnf -y install btop fastfetch vim && \
    dnf clean all

# Disable auto updates
RUN systemctl mask bootc-fetch-apply-updates.timer

RUN bootc container lint
