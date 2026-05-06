#! /bin/bash

## Fix permissions

## Make a bunch of files readable only by user

chmod -R 0400 ./npmrc

find ./aws ./docker ./ssh -type f -print0 | xargs -0 chmod 0400 

chmod 0700 ./aws ./docker ./ssh

## Loosen up some SSH file permissions - config, pub keys

chmod 0444 ./ssh/config
chmod 0444 ./ssh/authorized_keys
chmod 0444 ./ssh/*.pub

## Allow writes to ssh known_hosts and sockets

chmod 0644 ./ssh/known_hosts
chmod 0700 ./ssh/sockets
