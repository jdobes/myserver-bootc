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

systemctl mask custom-first-boot.service
echo "Masked custom-first-boot.service."
