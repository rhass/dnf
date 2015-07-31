#!/usr/bin/env python
#
# Query the dnf database for installed or available packages.
#
# This differs from dnf-repoquery in that it allows for querying
# packages based on version comparisons such as ">=".
#
# It also supports predictable sorting of package versions. The
# default behavior # is to show only the latest version. This can
# be changed with `--latest-limit=N`.
#
# Examples:
#
#   $ dnf-query.py tomcat
#   1:7.0.59-4.fc22.noarch
#
#   $ dnf-query.py tomcat --print-name
#   tomcat-1:7.0.59-4.fc22.noarch
#
#   $ dnf-query.py tomcat --installed
#   1:7.0.59-1.fc22.noarch
#
#   $ dnf-query.py tomcat '>=' 7.0.59-5
#   1:7.0.59-5.fc22.noarch
#   1:7.0.59-6.fc22.noarch
#
#   $ dnf-query.py sqlite.i686
#   3.8.10.2-1.fc22.i686
#
#   $ dnf-query.py sqlite.i686 '>= 3.7'
#   3.8.10.2-1.fc22.i686
#
#   $ dnf-query.py sqlite '>= 3.7' --latest-limit=3
#   3.8.10.2-1.fc22.i686
#   3.8.9-1.fc22.i686
#   3.8.10.2-1.fc22.x86_64
#   3.8.9-1.fc22.x86_64
#
#   $ dnf-query.py sqlite.i686 '>= 3.7' --latest-limit=3
#   3.8.10.2-1.fc22.i686
#   3.8.9-1.fc22.i686
#
#   $ dnf-query.py sqlite '>= 3.7' --latest-limit=1
#   3.8.10.2-1.fc22.i686
#   3.8.10.2-1.fc22.x86_64
#

import dnf

# map human readable comparison operators to dnf's query language
# http://dnf.readthedocs.org/en/latest/api_queries.html#dnf.query.Query.filter
COMPARATOR_MAP = {
    '=':  'eq',
    '!=': 'neq',
    '>':  'gt',
    '>=': 'gte',
    '<':  'lt',
    '<=': 'lte',
}


def get_sack():
    base = dnf.Base()
    base.read_all_repos()
    base.fill_sack()
    return base.sack


def run(args):
    name = args.name
    comparator = args.comparator
    version = None
    release = None

    if args.version:
        if '-' in args.version:
            version, release = args.version.split('-', 1)
        else:
            version = args.version
            release = None

    sack = get_sack()

    q = dnf.subject.Subject(name).get_best_query(sack)

    if args.installed:
        q = q.installed()
    else:
        q = q.available()

    kwargs = {}
    if version:
        kwargs['version__{}'.format(COMPARATOR_MAP[comparator])] = version
    if release:
        kwargs['release__{}'.format(COMPARATOR_MAP[comparator])] = release
    q = q.filter(**kwargs)

    pkgs = dnf.query.latest_limit_pkgs(q, args.latest_limit)

    for pkg in pkgs:
        if args.print_name:
            print '{}-{}:{}-{}'.format(pkg.name, pkg.epoch, pkg.version, pkg.release)
        else:
            print '{}:{}-{}'.format(pkg.epoch, pkg.version, pkg.release)


if __name__ == '__main__':
    import argparse

    # @TODO(joe): Do we need to support enable/disable repo commands (--repo NAME)
    #             since the dnf provider (inherited from yum) has some support
    #             for passing repo opts to dnf?
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('name', nargs='?',
                        help='The package name to query.')
    parser.add_argument('comparator', nargs='?',
                        help='comparsion function: =, >, >=, <, <=')
    parser.add_argument('version', nargs='?',
                        help='version specifier')

    parser.add_argument('--installed', action='store_true',
                       help='List installed packages instead of available packages.')
    parser.add_argument('--latest-limit', dest='latest_limit', type=int, default=1,
                       help='Show latest N matching patckages.')
    parser.add_argument('--print-name', dest='print_name', action='store_true',
                       help='Print package name(s).')
    args = parser.parse_args()

    run(args)
