#!/usr/bin/env python
#
# Query the dnf database for installed or available packages.
#
# This differs from dnf-repoquery in that it allows for querying
# packages based on version comparisons such as ">=".
#
# Examples:
#
#   $ dnf-query.py tomcat
#   tomcat-1:7.0.59-4.fc22.noarch
#
#   $ dnf-query.py tomcat --installed
#   tomcat-1:7.0.59-1.fc22.noarch
#
#   $ dnf-query.py tomcat '>=' 7.0.59-5
#   tomcat-1:7.0.59-5.fc22.noarch
#   tomcat-1:7.0.59-6.fc22.noarch
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


# @TODO(joe): do we need to consider someone wanting to match on the epoch too?
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
    q = sack.query()
    if args.installed:
        q = q.installed()
    else:
        q = q.available()

    kwargs = {}
    if name:
        kwargs['name'] = name
    if version:
        kwargs['version__{}'.format(COMPARATOR_MAP[comparator])] = version
    if release:
        kwargs['release__{}'.format(COMPARATOR_MAP[comparator])] = release
    q = q.filter(**kwargs)
        
    for pkg in q:
        print pkg


if __name__ == '__main__':
    import argparse

    # @TODO(joe): do we need to support enable/disable repo commands (--repo NAME)
    #             since the dnf provider (inherited from yum) has some support
    #             for passing repo opts to dnf.
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('name', nargs='?',
                        help='the package name to query')
    parser.add_argument('comparator', nargs='?',
                        help='comparsion function: =, >, >=, <, <=')
    parser.add_argument('version', nargs='?',
                        help='version specifier')

    parser.add_argument('--installed', action='store_true',
                       help='list installed packages instead of available packages')
    args = parser.parse_args()

    run(args)
