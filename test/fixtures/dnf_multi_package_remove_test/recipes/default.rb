if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12')
  package %w(which less) do
    action :remove
  end
else
  # chef 11 doesn't really support multi-package, but we still install them
  # here so that the serverspec tests will pass on chef 11
  %w(which less).each do |pkg|
    package pkg do
      action :remove
    end
  end
end
