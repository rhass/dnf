# -*- mode: ruby -*-
# vim: set ft=ruby:

source 'https://supermarket.chef.io/'
metadata

def test_cookbook(name)
  cookbook(name, path: ::File.join('test', 'cookbooks', name))
end

def site_cookbook(name)
  cookbook(name, git: 'git@github.com:pantheon-systems/infrastructure', rel: sprintf('site-cookbooks/%s', name))
end

def org_cookbook(name)
  cookbook(name, git: sprintf( 'git@github.com:pantheon-cookbooks/%s', name ))
end

# these are Mono repo cooks
%w().each do |c|
 site_cookbook c
end

# these are cookbook org cooks
%w().each do |c|
 org_cookbook c
end

group :test do
  test_cookbook 'dnf_test'
end
