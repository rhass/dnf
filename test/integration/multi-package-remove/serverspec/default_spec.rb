require 'spec_helper'

describe 'dnf_multi_package_remove_test::default' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe package('which') do
    it { should_not be_installed }
  end

  describe package('less') do
    it { should_not be_installed }
  end

end
