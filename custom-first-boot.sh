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

systemctl mask custom-first-boot.service
echo "Masked custom-first-boot.service."
