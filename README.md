dnf
===

Provide the dnf HWRP to Chef.

DNF is "dandified yum", a modern replacement for yum built on the libsolv library.

The current implementation differs from the existing yum package provider available in Chef
in a number of ways. It is significantly simpler than the yum provider and likely more
similar to the apt provider. See the examples and notes below for usage and differences to
the yum provider.

Additional use cases and features, including those from the yum provider, may be added in
the future.

Usage
-----

Default action is install:

    package 'foo'

Always upgrade to latest:

    package 'foo' do
      action :upgrade
    end

Install specific version:

    package 'foo' do
      version '1.0-1.fc22'
    end

Install specific arch:

    package 'glibc' do
      arch 'i686'
    end

Multi-package Support:

- Multi-package installs and removes are supported.
- `arch` attribute is supported. All packages in the multi-package group will use the same arch.
- `version` attribute is not supported with multi-package. (unless all packages share the same version)
- Multi-package is not supported on chef 11.x

Multi-package install:

    package %w(foo bar)

Multi-package remove:

    package %w(foo bar) do
      actin :remove
    end

TODOs
-----

Todos also sprinkled throughout the codebase. Here are some high-level/feature-based TODOs:

- [ ] get 12.3.0 and 12.4.0 support working properly.
- [ ] change references to `yum_timeout` to `dnf_timeout` (do we need this timeout or can we rely on package class timeout?)
- [x] support multi-package on chef-12
- [ ] implement package downgrading
- [x] test on chef 11 for pantheon?
- [x] support specifying `arch` as attribute
- [ ] support specifying version and arch in package name like yum_package does, eg: `package 'foo-1.0-1.fc22.i686'` ?
- [ ] support specifying version and arch in multi-package too, eg: `package %w(foo-1.0-1.fc22.i686 foo-1.0-1.fc22.x86_64)`
- [ ] support specifying whatprovides like: `package 'foo >= 1.2.3'` as yum_package does?
- [ ] should we support yum_package style 'whatprovides'? https://github.com/chef/chef/blob/23e3c799803ac1800149e27271c6168539cea25e/lib/chef/provider/package/yum.rb#L1329
