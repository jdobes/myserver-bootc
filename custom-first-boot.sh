#!/bin/bash

set -e

# Enable linger
user=$(ls /var/home/)
if [ $(echo "$user" | wc -w) -ne 1 ]; then
    echo "Single non-root user expected."
    exit 1
fi

loginctl enable-linger $user
echo "Linger enabled for $user."

cat >> /var/home/$user/.bashrc << "EOF"

PS1="[\[\e[96m\]\u\[\e[0m\]: \W\$(git branch 2> /dev/null | grep \-e '\* ' | sed 's/^..\(.*\)/ \[\e[92m\](\1)\[\e[0m\]/')]\$ "
alias caddy-reload="podman exec -w /etc/caddy caddy caddy reload"
EOF

gitconfig=/var/home/$user/.gitconfig
cat > $gitconfig << "EOF"
[user]
	name = Jan Dobes
	email = git@owny.cz
[core]
	editor = vim
EOF
chown $user:$user $gitconfig

systemctl --user -M $user@ enable --now podman-auto-update.timer

quadlet_sync_dir_cfg=/var/home/$user/.config/systemd/user/quadlet-sync.service.d
mkdir $quadlet_sync_dir_cfg
chown $user:$user $quadlet_sync_dir_cfg
cat > $quadlet_sync_dir_cfg/env.conf << "EOF"
[Service]
Environment=GIT_URL=https://<PAT>@github.com/jdobes/quadlets.git
Environment=GIT_SUBDIR=playground
EOF
chown $user:$user $quadlet_sync_dir_cfg/env.conf

systemctl --user -M $user@ enable --now quadlet-sync.timer

systemctl mask custom-first-boot.service
echo "Masked custom-first-boot.service."
