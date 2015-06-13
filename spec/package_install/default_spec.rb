#
# Cookbook Name:: dnf
# Spec:: default
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

require 'spec_helper'

describe 'dnf_package_install_test' do
  context 'When all attributes are default, on Fedora 22' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new(
        step_into: 'dnf_package',
        path: 'test/fixtures/fauxhai-fedora-22.json'
      ).converge(described_recipe)
    end

    it 'should install the nc6 package' do
      puts chef_run.node['platform_version']
      expect(chef_run).to install_dnf_package('nc6')
    end
  end
end
