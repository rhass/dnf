#!/bin/bash
# run test kitchen locally or remotely on the test-metal box
# if executing this script from circle-ci

set -ex

if [ "$CIRCLECI" = "true" ]; then
  TEST_METAL_SSH_USER="circleci"
  TEST_METAL_HOST="test-metal.getpantheon.com"

  git ls-files > /tmp/syncfiles
  rsync -rz -e "ssh -o GSSAPIAuthentication=no" --files-from /tmp/syncfiles ./ $TEST_METAL_SSH_USER@$TEST_METAL_HOST:/data/circleci/$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM/

  set +e

  ssh -A -t -o GSSAPIAuthentication=no $TEST_METAL_SSH_USER@$TEST_METAL_HOST "cd /data/circleci/$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM/ && kitchen test -c --destroy=passing"
  ret=$?

  set +x

  if [ $ret -gt 0 ]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo
    echo "   The build failed one or more test-kitchen suites."
    echo
    echo "   You can inspect the failed test environment by ssh'ing to the build server"
    echo "   where you can execute kitchen commands such as 'kitchen login'"
    echo
    echo "       ssh $TEST_METAL_HOST \"cd /data/circleci/$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM/ && bash --login\""
    echo
    echo "   When done, please run 'kitchen destroy' to cleanup the containers/VMs. "
    echo
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  fi
  exit $ret
else
  kitchen test -c 4 --destroy=passing
fi
