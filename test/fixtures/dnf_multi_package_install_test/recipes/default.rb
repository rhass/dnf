# we chose small packages with few dependencies to keep the
# test time low.

if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12')
  package %w(jq nano nc6) do
    action :install
  end
else
  # chef 11 doesn't really support multi-package, but we still install them
  # here so that the serverspec tests will pass on chef 11
  %w(jq nano nc6).each do |pkg|
    package pkg
  end
end
