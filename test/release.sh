#!/bin/bash

set -xe

# ensure we have autotag
if [ ! -d "$HOME/bin" ]; then
  mkdir -p ~/bin
fi

if [ ! -f "$HOME/bin/autotag" ]; then
  AUTOTAG_URL=$(curl -silent -o - -L https://api.github.com/repos/pantheon-systems/autotag/releases/latest | grep 'browser_' | cut -d\" -f4)
  # handle the off chance that this wont work with some pre-set version
  if [ -z "$AUTOTAG_URL" ] ;  then
    AUTOTAG_URL="https://github.com/pantheon-systems/autotag/releases/download/v0.0.3/autotag.linux.x86_64"
  fi
  curl -L $AUTOTAG_URL -o ~/bin/autotag
  chmod 755 ~/bin/autotag
fi

if ! grep -q 'email' ~/.gitconfig ; then
  git config --global user.email "infrastructure+circleci@getpantheon.com"
  git config --global user.name "CI"
fi

# tag/autoversion and write out metadata
VERSION=$(~/bin/autotag -n)

# replace version in metadata with new version, preserving whitespace
pattern='^\([[:blank:]]*\)version .*$'
sed -i "s/$pattern/\\1version '$VERSION'/" metadata.rb

# push
branch=$CIRCLE_BRANCH
if [ -z "$branch" ] ; then 
  branch="master"
fi

git add metadata.rb
git commit -m "auto release $VERSION [ci skip]"
git tag -a v$VERSION -m "auto release $VERSION" # one day we will parse metadata and add deps here
git push origin $branch
git push origin v$VERSION

# possibly wait for baryon ? for now we will just do a 2s wait
sleep 2

# trigger infra build
trigger_build_url=https://circleci.com/api/v1/project/pantheon-systems/infrastructure/tree/master?circle-token=${INFRA_BUILD_TOKEN}

post_data=$(cat <<EOF
{
  "build_parameters": {
    "COOKNAME": "$CIRCLE_PROJECT_REPONAME"
  }
}
EOF)

curl \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data "${post_data}" \
  --request POST ${trigger_build_url}
