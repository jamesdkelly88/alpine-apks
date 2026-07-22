#!/bin/sh
apk add alpine-sdk abuild sudo
adduser -D builder
addgroup builder abuild
echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
su builder
cd /packages/postgresql18-age
abuild-keygen -a -i -n
cp /home/builder/.abuild/builder-*.rsa* /packages/
abuild -r