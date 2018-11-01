#!/bin/sh

mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$SSH_PRIVATE_KEY" > ~/.ssh/docker-user
echo "$SSH_PUBLIC_KEY" > ~/.ssh/docker-user.pub
chmod 400 ~/.ssh/docker-user*
