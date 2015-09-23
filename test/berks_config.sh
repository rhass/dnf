#!/bin/bash
set -e

if [ -z "$CIRCLECI" ] ; then
  exit 0
fi

if [ -n "$GITHUB_TOKEN" ]; then
  if [ ! -d ~/.berkshelf ]; then
    mkdir ~/.berkshelf
  fi

  echo "configuring berks"
  cat << EOF > ~/.berkshelf/config.json
{
  "github": [{
    "access_token": "$GITHUB_TOKEN",
    "ssl_verify": true
  }]
}
EOF
fi
