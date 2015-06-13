# dnf_package 'nc6' do
#   action :install
# end

log 'OK' do
  only_if do
    Chef::Provider::Package::Dnf
  end
end

package 'nc6' do
  provider Chef::Provider::Package::Dnf
  action :install
end
