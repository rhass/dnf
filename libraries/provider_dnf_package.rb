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

require 'chef/provider/package'
require 'chef/resource/package'

# class Dnf provides a DNF specific package implementation
class Chef::Provider::Package::Dnf < Chef::Provider::Package
  if respond_to? :provides
    provides :package, platform: %w(fedora) do |node|
      node['platform_version'].to_f >= 22
    end

    provides :dnf_package, os: 'linux', platform_family: %w(rhel fedora)
  end

  def determine_new_resource_source
    @package_source_exists = false unless
      uri_scheme?(@new_resource.source) ||
      ::File.exist?(@new_resource.source)
  end

  def determine_and_set_rpm_candidate_version
    Chef::Log.debug("#{@new_resource} checking rpm status")
    shell_out_with_timeout!(
      "rpm -qp --queryformat '%{NAME} %{VERSION}-%{RELEASE}\n' #{@new_resource.source}"
    ).stdout.each_line do |line|
      case line
      when /^(?<package_name>[\w\d+_.-]+)\s(?<version>[\w\d~_.-]+)$/
        @current_resource.package_name Regexp.last_match[:package_name]
        @new_resource.version Regexp.last_match[:version]
        @candidate_version = Regexp.last_match[:version]
      end
    end
  end

  def determine_new_resource_rpm_installed
    shell_out_with_timeout(
      "rpm -q --queryformat '%{NAME} %{VERSION}-%{RELEASE}\n' #{@current_resource.package_name}"
    ).stdout.each_line do |line|
      case line
      when /^([\w\d+_.-]+)\s(?<version>[\w\d~_.-]+)$/
        version = Regexp.last_match[:version]
        Chef::Log.debug("#{@new_resource} current version is #{version}")
        @current_resource.version version
      end
    end
  end

  def load_current_resource
    @current_resource = Chef::Resource::Package.new(@new_resource.name)
    @current_resource.package_name(@new_resource.package_name)
    @new_resource.version(nil)

    if @new_resource.source
      determine_new_resource_source
      determine_and_set_rpm_candidate_version
    else
      if Array(@new_resource.action).include?(:install)
        @package_source_exists = false
        return
      end
    end

    Chef::Log.debug("#{@new_resource} checking install state")
    determine_new_resource_rpm_installed
    @current_resource
  end

  # Install the package with the dnf cli
  def install_package(name, version)
    package_source =
      if @new_resource.source
        @new_resource.source
      else
        sprintf('%s-%s', name, version)
      end

    shell_out_with_timeout!(
      sprintf(
        'dnf %s install %s',
        @new_resource.options,
        package_source
      )
    )
  end

  alias_method :upgrade_package, :install_package

  # Return the latest available version for a package.arch
  #  def candidate_version(package_name, arch = nil)
  # TODO(fujin): in order to drop yum-dump.py, we need to figure out how to do this via eager loading
  # version(package_name, arch, true, false)
  #  end
end
