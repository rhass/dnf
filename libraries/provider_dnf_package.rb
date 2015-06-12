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
  provides :package, platform: %w(fedora) do |node|
    node['platform_version'].to_f >= 22
  end if respond_to?(:provides)

  provides :dnf_package, os: 'linux', platform_family: %w(rhel fedora)

  def install_packge
  end

  def upgrade_package
  end

end
