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
      action :remove
    end

Performance differences from yum provider
-----------------------------------------

This provider does not pre-load all the package metadata at the first invocation
like the yum provider. This may make it less performant than the yum provider but
we have not benchmarked that yet.

We believe there are a number of problems with the pre-caching of the metadata
such as huge memory temporary demands and a delay in the chef run as the data is
loaded.

The dnf provider has the following characteristics:

1. For each package resource, a call to `rpm -q pkg` will be made to determine
   currently installed version. Anecdotally this takes ~50ms in a simple test VM
   with a basic fedora-22 install.
2. For each package resource, a call to the `dnf-query.py` helper will be made
   to determine available versions. Depending on the metadata expiration settings
   the dnf library may go fetch remote metadata. Thus, if you have any repos with
   metadata expiration set to `0` you will pay this penalty on every package call.
   We solved this in our environment with a short 5min expiration time. If
   `dnf-query.py` doesn't have to fetch remote data, then the exec will add ~250ms
   to the runtime.


TODOs
-----

Todos also sprinkled throughout the codebase. Here are some high-level/feature-based TODOs:

NOTE: some of these are unanswered questions around the theme of "should we make this compatbile with
the yum provider or not?". Our current thinking is not to unless there's a compelling reason.

- [x] get 12.3.0 and 12.4.0 support working properly.
- [x] change references to `yum_timeout` to `dnf_timeout` (do we need this timeout or can we rely on package class timeout?)
- [x] support multi-package on chef-12
- [ ] implement package downgrading
- [x] test on chef 11 for pantheon?
- [x] support specifying `arch` as attribute
- [ ] support specifying version and arch in package name like yum_package does, eg: `package 'foo-1.0-1.fc22.i686'` ?
- [ ] support specifying version and arch in multi-package too, eg: `package %w(foo-1.0-1.fc22.i686 foo-1.0-1.fc22.x86_64)`
- [ ] support specifying whatprovides like: `package 'foo >= 1.2.3'` as yum_package does?
- [ ] replace the `dnf-query.py` helper with a native ruby lib interface to dnf when/if one ever becomes available.
