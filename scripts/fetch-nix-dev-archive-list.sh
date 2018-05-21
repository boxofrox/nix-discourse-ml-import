#!/bin/bash

OUT_FILE=${1:-./archive-list.txt}
ARCHIVE_HOST=https://nixos.org/nix-dev

# AWK script to find and print archive URLs.
# \EOS disables bash expansion.
AWK_HREFS=$(cat - <<-\EOS
	/href="[^"]+\.gz"/ {
	  match($0, /href\="([^"]+\.gz)"/, m)
	  print m[1]
	}
	EOS
)

curl -sLk "$ARCHIVE_HOST" \
	| awk -f <(cat <<-SCRIPT
		$AWK_HREFS
	SCRIPT
	) \
	| sed -e "s|^|$ARCHIVE_HOST/|" \
	| tee "$OUT_FILE"
