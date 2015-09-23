all: spec fc rubo test_static test_integration
deps: install_chefdk chef12_hacks berks_config

test_static:
	sh test/static.sh

test_integration:
	sh test/integration.sh

validate_circle:
	ruby -r yaml -e 'puts YAML.dump(STDIN.read)' < circle.yml

spec:
	chef exec rspec  --format documentation --color test/spec

fc:
	chef exec foodcritic -f style,correctness,services,libraries,deprecated -X spec .

rubo:
	chef exec rubocop --fail-fast --fail-level convention --format simple --display-cop-names .

berks_config:
	sh test/berks_config.sh

chef12_hacks:
	chef gem install rest-client

install_chefdk:
	if [ ! -d ~/downloads ] ; then mkdir -p ~/downloads ; fi
	if [ ! -f ~/downloads/chefdk.deb ] ; then curl -o ~/downloads/chefdk.deb -L https://opscode-omnibus-packages.s3.amazonaws.com/debian/6/x86_64/chefdk_0.6.2-1_amd64.deb; fi
	sudo dpkg -i ~/downloads/chefdk.deb

release:
	bash test/release.sh

.PHONY: all
