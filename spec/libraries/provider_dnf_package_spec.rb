require 'rspec'
require_relative '../spec_helper'
require_relative '../../libraries/dnf_package'

describe Chef::Provider::Package::Dnf, 'load_current_resource' do
  before(:each) do
    @node = Chef::Node.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, {}, @events)
    @current_resource = Chef::Resource::Package.new('nc6')
    @new_resource = Chef::Resource::Package.new('nc6')
    @provider = Chef::Provider::Package::Dnf.new(@new_resource, @run_context)
    @provider.current_resource = @current_resource
  end

  describe 'when loading the current system state' do
    before(:each) do
      allow(@provider).to receive(:installed_version).and_return('0:1.0-21.fc22')
      allow(@provider).to receive(:available_version).and_return('0:1.0-30.fc22')
    end

    it 'should set the current resources package name to the new resources package name' do
      @provider.load_current_resource
      expect(@provider.current_resource.package_name).to eq('nc6')
    end

    # @TODO: support setting '.arch' in the package name like yum provider
    xit 'should set the arch if one is specified on the resource' do
      @new_resource.arch = 'x86_64'
      @provider.load_current_resource
      expect(@provider.arch).to eq 'x86_64'
    end

    it 'should not set the arch if one is not specified on the resource' do
      @provider.load_current_resource
    end

    it 'should set the installed version if rpm has one' do
      @provider.load_current_resource
      expect(@provider.current_resource.version).to eq '0:1.0-21.fc22'
    end

    it 'should set the candidate version if dnf has one' do
      @provider.load_current_resource
      expect(@provider.candidate_version).to eq '0:1.0-30.fc22'
    end

    it 'should set the installed version to nil on the current resource if no installed package' do
      expect(@provider).to receive(:installed_version).and_return(nil)
      @provider.load_current_resource
      expect(@provider.current_resource.version).to be_nil
    end

    describe 'and local rpm file is specified via source param' do
      before(:each) do
        allow(@new_resource).to receive(:source).and_return('nc6-1.0-21.fc22.x86_64.rpm')
        allow(@provider).to receive(:installed_version).and_return(nil)
      end

      it 'should raise exception if the file does not exist' do
        allow(File).to receive(:exist?).with('nc6-1.0-21.fc22.x86_64.rpm').and_return(false)
        expect { @provider.load_current_resource }.to raise_exception(Chef::Exceptions::Package, 'Package nc6 not found: nc6-1.0-21.fc22.x86_64.rpm')
      end

      it 'should set the candidate version to the version of the local rpm file' do
        allow(File).to receive(:exist?).with('nc6-1.0-21.fc22.x86_64.rpm').and_return(true)
        rpm_query_double = double('Status', exitstatus: 0, stdout: "0:1.0-21.fc22\n")
        allow(@provider).to receive(:shell_out!).and_return(rpm_query_double)

        @provider.load_current_resource
        expect(@provider.candidate_version).to eq '0:1.0-21.fc22'
      end
    end
  end

  describe 'when querying for package state' do
    it 'should set the version number when the package is installed' do
      rpm_query_double = double('Status', exitstatus: 0, stdout: "0:1.0-21.fc22\n")
      allow(@provider).to receive(:shell_out!).and_return(rpm_query_double)
      expect(@provider.installed_version('nc6')).to eq('0:1.0-21.fc22')
    end

    it 'does not set the current version when the package is not installed' do
      rpm_query_double = double('Status', exitstatus: 1, stdout: "package nc6. is not installed\n")
      allow(@provider).to receive(:shell_out!).and_return(rpm_query_double)
      expect(@provider.installed_version('nc6')).to be_nil
    end

    it 'should set the version number when there is an available package' do
      dnf_query_double = double('Status', exitstatus: 0, stdout: "0:1.0-30.fc22\n")
      allow(@provider).to receive(:shell_out!).and_return(dnf_query_double)
      expect(@provider.available_version('nc6')).to eq('0:1.0-30.fc22')
    end

    it 'should not set the version number when there is not an available package' do
      dnf_query_double = double('Status', exitstatus: 0, stdout: "\n")
      allow(@provider).to receive(:shell_out!).and_return(dnf_query_double)
      expect(@provider.available_version('nc6')).to be_nil
    end
  end

  describe 'install_package, when installing a single package' do
    it 'should run dnf install with the package name and available version' do
      dnf_install_double = double('Status', exitstatus: 0)
      expect(@provider).to receive(:shell_out!).with("dnf #{@provider.new_resource.options} -qy install nc6-0:1.0-30.fc22").and_return(dnf_install_double)
      @provider.install_package('nc6', '0:1.0-30.fc22')
    end
  end

  describe 'install_package, when installing multiple packages' do
    it 'should run dnf install with the package name and version of each package' do
      expect(@provider).to receive(:shell_out!).with("dnf #{@provider.new_resource.options} -qy install nc6-0:1.0-1.fc22 jq-0:2.0-2.fc22")
      @provider.install_package(%w(nc6 jq), %w(0:1.0-1.fc22 0:2.0-2.fc22))
    end
  end

  describe 'remove_package, when removing a single package' do
    it 'should run dnf remove with the package name and available version' do
      dnf_install_double = double('Status', exitstatus: 0)
      expect(@provider).to receive(:shell_out!).with("dnf #{@provider.new_resource.options} -qy remove nc6-0:1.0-21.fc22").and_return(dnf_install_double)
      @provider.remove_package('nc6', '0:1.0-21.fc22')
    end
  end

  describe 'remove_package, when removing multiple packages' do
    it 'should run dnf install with the package name and version of each package' do
      expect(@provider).to receive(:shell_out!).with("dnf #{@provider.new_resource.options} -qy remove nc6-0:1.0-1.fc22 jq-0:2.0-2.fc22")
      @provider.remove_package(%w(nc6 jq), %w(0:1.0-1.fc22 0:2.0-2.fc22))
    end
  end
end
