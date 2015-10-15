#
# Author:: AJ Christensen (<aj@junglistheavy.industries>)
# Author:: Joe Miller (<joeym@joeym.net>)
# Copyright:: Copyright (c) 2015 Pantheon Systems, Ltd
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/resource/package'
require_relative 'provider_dnf_package'

# class DnfPackage subclasses the package resource with DNF specific attributes
unless Chef::Resource.const_defined?('DnfPackage')
  Chef::Log.info('Loading DNF package resource from cookbook')

  class Chef::Resource::DnfPackage < Chef::Resource::Package
    provides :dnf_package if self.respond_to?(:provides)

    chef_version = Gem::Version.new(Chef::VERSION)

    # chef >= 12.4.0
    provides :package, platform: 'fedora', platform_version: '>= 22' if chef_version >= Gem::Version.new('12.4.0')

    # chef 12.0.0 - 12.3.0
    if chef_version >= Gem::Version.new('12.0.0') && chef_version < Gem::Version.new('12.4.0')
      provides :package, platform: 'fedora' do |node|
        Chef::VersionConstraint::Platform.new('>= 22').include?(node['platform_version']) if node['platform_version']
      end
    end

    # chef < 12.0 (tested on chef-11 only)
    if chef_version < Gem::Version.new('12.0.0')
      Chef::Platform.set platform: :fedora, version: '>= 22', resource: :package, provider: Chef::Provider::Package::Dnf
    end

    def initialize(name, run_context = nil)
      super
      @resource_name = :dnf_package
      @provider = Chef::Provider::Package::Dnf

      @allow_downgrade = false
    end

    # Install a specific arch
    # @TODO(joe): implement arch
    def arch(arg = nil)
      set_or_return(
        :arch,
        arg,
        kind_of: [String, Array]
      )
    end

    # @TODO(joe): implement downgrade support in provider
    def allow_downgrade(arg = nil)
      set_or_return(
        :allow_downgrade,
        arg,
        kind_of: [TrueClass, FalseClass]
      )
    end
  end
end
