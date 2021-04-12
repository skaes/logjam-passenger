name "logjam-passenger"

require 'yaml'
versions = YAML::load_file(File.expand_path(__dir__)+"/versions.yml")

v, i = versions["package"].split('-')
version v
iteration i

vendor "skaes@railsexpress.de"

build_depends "build-essential"
build_depends "curl"
build_depends "git"
build_depends "nodejs"

if codename == "trusty"
  build_depends "apache2-threaded-dev"
else
  build_depends "apache2-dev"
end
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

depends "logjam-ruby", ">= 3.0.1"
depends "apache2"
if codename == "trusty"
  depends "apache2-mpm-worker"
end

apt_setup "apt-get update -y && apt-get install apt-transport-https ca-certificates -y"
apt_setup "echo 'deb [trusted=yes] https://railsexpress.de/packages/ubuntu/#{codename} ./' >> /etc/apt/sources.list"

add "install-passenger-nginx-module.sh", ".install-passenger-nginx-module.sh"
add "install-passenger-apache2-module.sh", ".install-passenger-apache2-module.sh"
add "minify-passenger-install.sh", ".minify-passenger-install.sh"
add "passenger.load", ".passenger.load"

run "/opt/logjam/bin/gem", "install", "passenger", "-v", versions["passenger"]
run "./.install-passenger-nginx-module.sh"
run "./.install-passenger-apache2-module.sh"
run "./.minify-passenger-install.sh", versions["passenger"]

run "cp", ".passenger.load", "/etc/apache2/mods-available/passenger.load"
run "chmod", "644", "/etc/apache2/mods-available/passenger.load"
