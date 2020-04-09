#! /bin/bash

cd $(dirname $0)
here=$(pwd -P)
archive=${HOME}/.pre-dotfiles-stanford

mkdir -p ${archive}

# Initialize / update any git submodules

if [ -f .gitmodules ]; then
  echo Updating git submodules
  git submodule init
  git submodule update
fi

# Unlock encrypted files

if [ -d .git-crypt ]; then
  echo Unlocking encrypted files
  git-crypt unlock
fi

# Fix permissions

## Make a bunch of files readable only by user

chmod -R 0400 ${here}/s3cfg* ${here}/npmrc

find ${here}/aws ${here}/docker ${here}/ssh -type f | xargs chmod 0400 

chmod 0700 ${here}/aws ${here}/docker ${here}/ssh

## Loosen up some SSH file permissions - config, pub keys

chmod 0444 ${here}/ssh/config
chmod 0444 ${here}/ssh/authorized_keys
chmod 0444 ${here}/ssh/*.pub

## Allow writes to ssh known_hosts and sockets

chmod 0644 ${here}/ssh/known_hosts
chmod 0700 ${here}/ssh/sockets

# (Re-)Link files

for file in *; do
  [ $file == $(basename $0) ] && continue;
  link=${HOME}/.${file}
  if [ -e ${link} -a ! -L ${link} ]; then
    echo Saving old .${file}
    mv -f ${link} ${archive}
  fi
  echo Linking ${file}
  ln -sfh ${here}/${file} ${link}
done

