#!/bin/bash

# replace File.exists? with File.exist?
# we can probably remove this line in the next release 6.0.17

set -e

pushd /opt/logjam/lib/ruby/gems/$2/gems/passenger-$1
perl -pi -e 's/File.exists\?/File.exist?/g' test/integration_tests/nginx_tests.rb
perl -pi -e 's/File.exists\?/File.exist?/g' src/ruby_supportlib/phusion_passenger/platform_info/operating_system.rb
perl -pi -e 's/File.exists\?/File.exist?/g' src/ruby_native_extension/extconf.rb
popd
