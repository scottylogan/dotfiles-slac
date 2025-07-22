#! /bin/bash

cd "$(dirname "${0}")" || exit

here=$(pwd -P)
relative=${here/$HOME\//}

link="/bin/ln -sfh"
[[ -f /etc/os-release ]] && link="ln -sfn"

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

# (Re-)Link files

for file in *; do
  [ "${file}" == "config" ] && continue;
  [ "${file}" == "$(basename "${0}")" ] && continue;
  target=${HOME}/.${file}
  echo Linking "${file}"
  ${link} "${relative}/${file}" "${target}"
done

# handle config directory, which is shared between this repo and others
if [ -d config ]; then
  # make ~/.config if it doesn't exist
  [ -d "${HOME}/.config" ] || mkdir "${HOME}/.config"

  for thing in config/*; do
    target="${HOME}/.config/$(basename "${thing}")"
    echo Linking ".${thing}"
    ${link} "${HOME}/${relative}/${thing}" "${target}"
  done
fi

# Fix permissions

## Make a bunch of files readable only by user

chmod -R 0400 "${here}/npmrc"

find "${here}/aws" "${here}/docker" "${here}/ssh" -type f -print0 | xargs -0 chmod 0400 

chmod 0700 "${here}/aws" "${here}/docker" "${here}/ssh"

## Loosen up some SSH file permissions - config, pub keys

chmod 0444 "${here}/ssh/config"
chmod 0444 "${here}/ssh/authorized_keys"
chmod 0444 "${here}/ssh/"*.pub

## Allow writes to ssh known_hosts and sockets

chmod 0644 "${here}/ssh/known_hosts"
chmod 0700 "${here}/ssh/sockets"


