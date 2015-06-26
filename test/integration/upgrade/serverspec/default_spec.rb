require 'spec_helper'

describe 'dnf_package_upgrade_test::default' do

  describe package('sqlite') do
    it { should be_installed }
  end

end
