# logjam-passenger

Build Debian packages of Phusion Passenger for logjam pipeline.

[![build](https://github.com/skaes/logjam-passenger/actions/workflows/build.yml/badge.svg)](https://github.com/skaes/logjam-passenger/actions/workflows/build.yml)

## Usage

Edit file `versions.yml`, change the version numbers of package and passenger gem and push
to Github.

The GitHub Actions pipeline will then build go packages for Focal, Bionic and Xenial and
upload them to [railsexpress.de](https://railsexpress.de/packages/ubuntu/).

To create the packages locally, run `make packages`.
