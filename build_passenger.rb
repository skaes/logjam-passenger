name "logjam-passenger"

require 'yaml'
versions = YAML::load_file(File.expand_path(__dir__)+"/versions.yml")

ruby_version = versions["ruby"]
ruby_lib_version = (ruby_version.split(".")[0..1] << "0").join('.')

v, i = versions["package"].split('-')
version v
iteration i

vendor "skaes@railsexpress.de"

build_depends "build-essential"
build_depends "curl"
build_depends "git"
build_depends "nodejs"
build_depends "apache2-dev"
build_depends "libapr1-dev"
build_depends "libcurl4-openssl-dev"
build_depends "libffi-dev"
build_depends "libgdbm-dev"
build_depends "libgmp-dev"
build_depends "libncurses5-dev"
build_depends "libreadline6-dev"
build_depends "libssl-dev"
build_depends "libtool"
build_depends "libyaml-dev"
build_depends "pkg-config"
build_depends "zlib1g-dev"
build_depends "libpcre3-dev"

depends "logjam-ruby", ">= #{ruby_version}"
depends "apache2"

apt_setup "apt-get update -y && apt-get install apt-transport-https ca-certificates -y"
apt_setup "echo 'deb [trusted=yes] https://railsexpress.de/packages/ubuntu/#{codename} ./' >> /etc/apt/sources.list"

add "install-passenger-standalone.sh", ".install-passenger-standalone.sh"
add "install-passenger-nginx-module.sh", ".install-passenger-nginx-module.sh"
add "install-passenger-apache2-module.sh", ".install-passenger-apache2-module.sh"
add "minify-passenger-install.sh", ".minify-passenger-install.sh"
add "passenger.load", ".passenger.load"

run "/opt/logjam/bin/gem", "install", "passenger", "-v", versions["passenger"]
run "./.install-passenger-standalone.sh"
run "./.install-passenger-nginx-module.sh"
run "./.install-passenger-apache2-module.sh"
run "./.minify-passenger-install.sh", versions["passenger"], ruby_lib_version

run "cp", ".passenger.load", "/etc/apache2/mods-available/passenger.load"
run "chmod", "644", "/etc/apache2/mods-available/passenger.load"

# When running in a tty, tzdata asks for the time zone and the next
# line fixes that problem.
plugin "env", "DEBIAN_FRONTEND" => "noninteractive"
