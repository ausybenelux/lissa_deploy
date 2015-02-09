# LISSA Deploy

LISSA deploy uses Capistrano 3 to deploy [LISSA Kickstart](https://github.com/ONEAgency/lissa_kickstart)

You can use it to deploy servers or a Vagrant box provisioned with [LISSA infrastructure](https://github.com/ONEAgency/lissa_infrastructure).

## Requirements

- Ruby 1.9.3 or newer
- [Bundler](http://bundler.io/) 1.6 or newer

## Installation

After cloning the repository execute:

`bundle install --path=vendor`

## Usage

You can add servers to deploy to by copying the config/deploy/local.rb file and
adding credentials for your own servers. LISSA deploy already comes with a local server configuration that can be used to deploy LISSA Kickstart to the Vagrant box set up with [LISSA infrastructure](https://github.com/ONEAgency/lissa_infrastructure).

After setting up your servers execute a deploy with the following command:

`bundle exec cap server-name deploy`

This will deploy LISSA Kickstart to the server configured in the config/deploy/server-name.rb file.

To deploy the Vagrant box use:

`bundle exec cap local deploy`
