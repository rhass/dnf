if defined?(ChefSpec)
  ChefSpec.define_matcher :dnf_package

  # @example This is an example
  #   expect(chef_run).to install_dnf_package('foo')
  #
  # @param [String] resource_name
  #   the resource name
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def install_dnf_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:dnf_package, :install, resource_name)
  end

  def upgrade_dnf_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:dnf_package, :upgrade, resource_name)
  end

  def remove_dnf_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:dnf_package, :remove, resource_name)
  end
end
