#!/bin/bash

PATH=/opt/logjam/bin:$PATH

# download passenger support binaries and build native support runtime
passenger-config install-standalone-runtime
passenger-config build-native-support
