# vim: set ft=ruby:
# -*- mode: ruby -*-
source 'https://baryon.gce.panth.io/'

metadata

def fixture_cookbook(name)
  cookbook(name, path: ::File.join('test', 'fixtures', name))
end

group :test do
  fixture_cookbook 'dnf_package_install_test'
  fixture_cookbook 'dnf_package_upgrade_test'
  fixture_cookbook 'dnf_package_remove_test'
  fixture_cookbook 'dnf_multi_package_install_test'
  fixture_cookbook 'dnf_multi_package_remove_test'
end
