require_relative 'provider_dnf_package'

Chef::Platform.set platform: :fedora, resource: :dnf_package, provider: Chef::Provider::Package::Dnf
# Chef::Platform.set platform: :fedora, version: '>= 22', resource: :package, provider: Chef::Provider::Package::Dnf

Chef::Log.debug 'setting default package provider to dnf'
Chef::Platform.set(
  platform: :fedora,
  resource: :package,
  provider: Chef::Provider::Package::Dnf
)
