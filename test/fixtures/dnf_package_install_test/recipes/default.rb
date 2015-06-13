# install a few packages using the various forms of accessing
# the dnf package provider.
#
# we chose small packages with few dependencies to keep the
# test time low.

dnf_package 'jq' do
  action :install
end

package 'vim-enhanced' do
  provider Chef::Provider::Package::Dnf
  action :install
end

package 'nc6' do
  action :install
end
