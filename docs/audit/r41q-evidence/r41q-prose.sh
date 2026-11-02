#!/usr/bin/env bash
# web-prose.sh : wolf-web's three prose checks at the head clone, as build.sh
# calls them; every check runs and prints its exit.
cd /home/mfwolffe/lanes/r41q/web/new || exit 1
python3 scripts/check-version-prose.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp; echo "END version-prose exit=$?"
python3 scripts/check-counts.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book; echo "END counts exit=$?"
python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp; echo "END lag-phrases exit=$?"
