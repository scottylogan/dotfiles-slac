#! /bin/bash

# handle files under config-overlay directory, which is shared between this repo and others
if [ -d config-overlay ]; then
  find config-overlay -type f | while read -r overlay; do
    src=${overlay/config-overlay\//}
    target="${HOME}/.config/${src}"
    link "${target}" "${RELATIVE}/${overlay}"
  done
fi

