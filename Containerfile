FROM quay.io/centos-bootc/centos-bootc:stream10

RUN dnf config-manager --set-enabled crb && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

RUN dnf -y install btop fastfetch git vim && \
    dnf clean all

# Setting up permissions for rootless podman
RUN echo "net.ipv4.ip_unprivileged_port_start=53" >> /etc/sysctl.conf

# It's crashing currently and also don't need it
RUN systemctl mask rpm-ostree-countme.timer

# Other settings
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config.d/custom.conf && \
    echo "Port 57657" >> /etc/ssh/sshd_config.d/custom.conf
RUN rm -f /etc/motd.d/insights-client

# Setting up script to run on first boot when user exists
ADD custom-first-boot.sh      /usr/local/sbin
ADD custom-first-boot.service /usr/lib/systemd/system/
RUN systemctl enable custom-first-boot.service

RUN bootc container lint || true
