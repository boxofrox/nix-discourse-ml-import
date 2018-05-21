#!/bin/bash

set -eu -o pipefail

usage() {
  cat >&2 <<USAGE
Usage: $(basename "$0") [-h] DEST_DIR <URL_LIST

Options:
  DEST_DIR      Destination folder to store files.
  URL_LIST      List of URLs.  One URL per line.
USAGE
  exit 1
}

err() {
  echo "$@" >&2
}

fatal() {
  err "$@"
  err
  exit 1
}

# compare remote and local file sizes and return success if sizes match,
# otherwise return an error code.
is-already-fetched() {
  local url="$1" file=$(basename "$1") remote_size=0 local_size=0

  remote_size=$(curl -sI --head "$url" | grep -i content-length | tail -n1 | cut -d' ' -f2 | tr -d '\r\n')

  if [[ -f "$file" ]]; then
    local_size=$(stat --printf "%s" "$file")
    test $local_size -gt 0 -a $local_size -eq $remote_size
  else
    return 1
  fi
}

DEST_DIR=${1:-''}

if ! type curl >/dev/null 2>&1; then
  fatal "'curl' command not found"
elif [[ -z "$DEST_DIR" ]]; then
  err "Missing DEST_DIR"
  err
  usage
elif [[ "-h" = "$DEST_DIR" ]]; then
  usage
elif [[ ! -d "$DEST_DIR" ]]; then
  err "DEST_DIR is not a directory"
  err
  usage
fi

cd "$DEST_DIR" || fatal "Cannot access folder \"$DEST_DIR\""

while read URL; do
  if ! is-already-fetched "$URL"; then
    err "not already fetched: $URL"
    curl -skLO "$URL" && echo "PASS $URL" || echo "FAIL $URL"
  else
    err "already fetched: $URL"
  fi
done

err "Done."
