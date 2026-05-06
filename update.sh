#! /bin/bash

prog=$(basename "${0}")
progdir=$(dirname "${0}")

cd "${progdir}" || exit

DEBUG=0
RELATIVEPATHS=0
last=

function usage {
  echo "Usage: ${prog} [-d] [-d n]" >&2
  exit 1
}

for opt in "${@}"; do
  case "${opt}" in
    "-r")
      RELATIVEPATHS=1
      ;;
    "-d")
      DEBUG=$((DEBUG + 1))
      ;;
    1|2)
      if [ "${last}" == "-d" ]; then
        DEBUG="${opt}"
      else
        usage
      fi
      ;;
    *)
      usage
      ;;
  esac
  last="${opt}"
done

function debug {
  level=$1
  shift
  [ "${DEBUG}" -ge "${level}" ] && echo "${@}"
}

function debug1 {
  debug 1 "${@}"
}

function debug2 {
  debug 2 "${@}"
}

HERE=$(pwd -P)
RELATIVE=${HERE/$HOME\//}

LINK="/bin/ln -sfh"
[[ -f /etc/os-release ]] && LINK="ln -sfn"

export HERE LINK RELATIVE

# Usage link target src
function link {
  target=$1
  src=${2/$HOME\//}
  [ "${RELATIVEPATHS}" == 0 ] && src="${HOME}/${src}"
  stat=$(/usr/bin/stat -f %Y "${target}" 2>/dev/null)
  if [ -e "${target}" ] && [ "${stat}" == "${src}" ]; then
    debug2 "Skipping ${target} - already linked to ${src}"
    return
  fi
  debug1 Linking "${src} to ${target}"
  ${LINK} "${src}" "${target}"
}

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
  case "${file}" in
    config|config-overlay|LICENSE|*.sh|*.md)
      # skip config, config-overlay, LICENSE, Markdown files, and any scripts
      continue
      ;;
    *)
      link "${HOME}/.${file}" "${RELATIVE}/${file}"
      ;;
  esac
done

# handle config directory, which is shared between this repo and others
if [ -d config ]; then
  # make ~/.config if it doesn't exist
  [ -d "${HOME}/.config" ] || mkdir "${HOME}/.config"

  for thing in config/*; do
    target="${HOME}/.config/$(basename "${thing}")"
    link "${target}" "${HOME}/${RELATIVE}/${thing}"
  done
fi

# Run helper scripts

if [ -d ./helpers ]; then
  for helper in helpers/*.sh; do
    echo Running "${helper}"
    #shellcheck source=/dev/null
    . "${helper}"
  done
fi
