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
podman-set-secret() { printf "$2" | podman secret create --replace $1 - ; }
EOF

gitconfig=/var/home/$user/.gitconfig
quadlets_symlink=/var/home/$user/quadlets
volumes_symlink=/var/home/$user/volumes
cat > $gitconfig << "EOF"
[user]
	name = Jan Dobes
	email = git@owny.cz
[core]
	editor = vim
EOF
chown $user:$user $gitconfig

ln -s .config/containers/systemd/ $quadlets_symlink
ln -s .local/share/containers/storage/volumes/ $volumes_symlink
chown -h $user:$user $quadlets_symlink $volumes_symlink

quadlet_sync_dir_cfg=/var/home/$user/.config/systemd/user/quadlet-sync.service.d
mkdir $quadlet_sync_dir_cfg
cat > $quadlet_sync_dir_cfg/env.conf << "EOF"
[Service]
Environment=GIT_URL=https://<PAT>@github.com/jdobes/quadlets.git
Environment=GIT_SUBDIR=playground
EOF
chown -R $user:$user $quadlet_sync_dir_cfg

systemctl mask custom-first-boot.service
echo "Masked custom-first-boot.service."
