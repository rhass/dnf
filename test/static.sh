#!/bin/bash
set -e
set -x

if which pylint ; then
  find . -name \*.py -exec grep -q pylint {} \; -print0 | xargs -0 python -m py_compile
  find . -name \*.py -exec grep -q pylint {} \; -print0 | xargs -0 pylint
fi

find . -name "*.json" -print | grep -v '/test/' | grep -v 'vendor' | xargs -Ixx bash -c "echo JSON linting xx 1>&2; cat xx | python -mjson.tool > /dev/null || exit 255"

if which php ; then
  find . -name \*.php* -exec php -l {} \;
fi
