FROM quay.io/centos-bootc/centos-bootc:stream10@sha256:1103272b7ed87dd03e9e622dd418f6af51e29139fd73742ef585acee493f460b

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
RUN mkdir -p /etc/systemd/logind.conf.d/ && \
    echo "[Login]" >> /etc/systemd/logind.conf.d/lidswitch.conf && \
    echo "HandleLidSwitch=ignore" >> /etc/systemd/logind.conf.d/lidswitch.conf

# Setting up script to run on first boot when user exists
ADD custom-first-boot.sh                     /usr/local/sbin
ADD systemd/system/custom-first-boot.service /usr/lib/systemd/system/

RUN systemctl enable custom-first-boot.service

ADD quadlet-sync                            /usr/local/bin
ADD systemd/user/quadlet-sync.service       /usr/lib/systemd/user
ADD systemd/user/quadlet-sync.timer         /usr/lib/systemd/user
ADD systemd/user/podman-image-prune.service /usr/lib/systemd/user
ADD systemd/user/podman-image-prune.timer   /usr/lib/systemd/user

RUN bootc container lint || true
