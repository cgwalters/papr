#!/bin/bash
set -euo pipefail

# This is a hacky workaround so that the main script will
# work seamlessly wrt the ssh keyfile regardless of whether
# it's run in a container or directly.

if [ -n "${os_keyfile:-}" ]; then
	if [[ $os_keyfile != /* ]]; then
		echo "ERROR: os_keyfile must be absolute."
		exit 1
	fi
	mkdir -m 0700 /ssh
	cp /host/$os_keyfile /ssh
	bn=$(basename $os_keyfile)
	chmod 0600 /ssh/$bn
	export os_keyfile=/ssh/$bn
fi

exec /redhat-ci/main
