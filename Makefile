all: spec fc rubo test_static test_integration  
deps: install_chefdk metadata_json

test_static:
	sh test/static.sh

test_integration:
	sh test/integration.sh

validate_circle:
	ruby -r yaml -e 'puts YAML.dump(STDIN.read)' < circle.yml

spec:
	chef exec rspec  --format documentation --color test/spec

fc:
	chef exec foodcritic -f style,correctness,services,libraries,deprecated .

rubo:
	chef exec rubocop --fail-fast --fail-level convention --format simple --display-cop-names .

metadata_json:
	knife cookbook metadata .

install_chefdk:
	if [ ! -d ~/downloads ] ; then mkdir -p ~/downloads ; fi
	if [ ! -f ~/downloads/chefdk.deb ] ; then curl -o ~/downloads/chefdk.deb -L	https://opscode-omnibus-packages.s3.amazonaws.com/debian/6/x86_64/chefdk_0.4.0-1_amd64.deb ; fi
	sudo dpkg -i ~/downloads/chefdk.deb

.PHONY: all
