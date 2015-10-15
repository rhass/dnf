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
require 'chef/mixin/shell_out'

# class Dnf provides a DNF specific package implementation
unless Chef::Provider::Package.const_defined?('Dnf')
  Chef::Log.info('Loading DNF package provider from cookbook')

  class Chef::Provider::Package::Dnf < Chef::Provider::Package
    include Chef::Mixin::ShellOut

    def determine_new_resource_source
      @package_source_exists = false unless
        uri_scheme?(@new_resource.source) ||
        ::File.exist?(@new_resource.source)
    end

    def load_current_resource
      if @new_resource.options
        repo_control = []
        @new_resource.options.split.each do |opt|
          repo_control << opt if opt =~ /--(enable|disable)repo=.+/
        end
      end

      @current_resource = Chef::Resource::Package.new(@new_resource.name)
      @current_resource.package_name(@new_resource.package_name)

      installed_version = []
      @candidate_version = []
      if @new_resource.source
        fail(
          Chef::Exceptions::Package,
          "Package #{@new_resource.name} not found: #{@new_resource.source}"
        ) unless ::File.exist?(@new_resource.source)

        Chef::Log.debug("#{@new_resource} checking rpm status")
        shell_out!(
          "rpm -qp --queryformat '%{EPOCHNUM}:%{VERSION}-%{RELEASE}.%{ARCH}\n' #{@new_resource.source}"
        ).stdout.each_line do |line|
          @new_resource.version line.chomp unless line.chomp.empty?
        end

        @candidate_version << @new_resource.version
        installed_version << installed_version(@current_resource.package_name)
      else
        if @new_resource.version
          new_resource = "#{@new_resource.package_name}-#{@new_resource.version}#{dnf_arch}"
        else
          new_resource = "#{@new_resource.package_name}#{dnf_arch}"
        end

        Chef::Log.debug("#{@new_resource} checking dnf info for #{new_resource}")

        package_names = self.respond_to?(:package_name_array) ? package_name_array : [@new_resource.package_name].flatten
        package_names.each do |pkg|
          installed_version << installed_version(pkg)
          @candidate_version << available_version(pkg)
        end

      end

      if installed_version.size == 1
        @current_resource.version(installed_version[0])
        @candidate_version = @candidate_version[0]
      else
        @current_resource.version(installed_version)
      end

      Chef::Log.debug("#{@new_resource} installed version: #{installed_version || '(none)'} candidate version: #{@candidate_version || '(none)'}")

      @current_resource
    end

    # Return the currently installed version for a package.arch
    def installed_version(package_name)
      Chef::Log.debug("#{@new_resource} checking rpm installed state")
      cmd = shell_out!(
        "rpm -q --queryformat '%{EPOCHNUM}:%{VERSION}-%{RELEASE}.%{ARCH}\n' #{package_name}#{dnf_arch}",
        returns: [0, 1]
      )
      cmd.exitstatus == 0 ? cmd.stdout.chomp : nil
    end

    def dnf_query_helper
      ::File.join(::File.dirname(__FILE__), 'dnf-query.py')
    end

    # Return the latest available version for a package.arch, else 'nil' if no packages available
    def available_version(package_name)
      Chef::Log.debug("#{@new_resource} checking dnf for available version")
      version = nil
      cmd = shell_out!(
        "#{dnf_query_helper} #{package_name}#{dnf_arch}"
      )
      first_line = cmd.stdout.lines.first
      unless first_line.nil?
        version = first_line.chomp unless first_line.chomp.empty?
      end
      version
    end

    def dnf_arch
      arch ? ".#{arch}" : nil
    end

    def arch
      @new_resource.arch if @new_resource.respond_to?(:arch)
    end

    # return a string containing one or more package name-version.arch's
    # that can be used by install_package and remove_package for
    # multi-package support
    def package_spec(name, version)
      name_array = [name].flatten
      version_array = [version].flatten
      name_array.zip(version_array).map do |n, v|
        sprintf('%s-%s%s', n, v, dnf_arch)
      end.join(' ')
    end

    # Install one or more packages with the dnf cli
    def install_package(name, version)
      package_source =
        if @new_resource.source
          # local rpm install
          @new_resource.source
        else
          package_spec(name, version)
        end

      shell_out!(
        sprintf(
          'dnf %s -qy install %s',
          @new_resource.options,
          package_source
        )
      )
    end

    alias_method :upgrade_package, :install_package

    # remove one or more packages with the dnf cli
    def remove_package(name, version)
      package_source = package_spec(name, version)
      shell_out!(
        sprintf(
          'dnf %s -qy remove %s',
          @new_resource.options,
          package_source
        )
      )
    end
  end
end
