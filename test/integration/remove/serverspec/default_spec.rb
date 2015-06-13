require 'spec_helper'

describe 'dnf_package_remove_test::default' do

  describe package('which') do
    it { should_not be_installed }
  end

end
