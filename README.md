# Roempro - Oempro Ruby Wrapper

It aims to easily deal with the API of a given Oempro application.

## Installation

### Using Gemfile

Add this line to your application's Gemfile:

    gem 'roempro'

And then execute:

    $ bundle install

### By hand

Install it yourself as:

    $ gem install roempro

## Usage

### Rails 3

After installing the gem, run the rails generator to populate the `config` and `config/initializers` directories

    $ rails g roempro:install

Set up the configuration in `config/roempro.yml`

    production:
        url:      path_to_oempro_api
        username: oempro_user
        password: oempro_password

This will set up a default configuration use by Roempro.

**Don't forget to restrict the permitions on the file.**

    $ chmod 600 config/roempro.yml

### Ruby and others frameworks

The default configuration can also be set using Roempro::Config object, as

    irb > Roempro::Config.load_from_hash :url => "path_to_oempro",
                                         :username => "oempro_user",
                                         :password => "oempro_password"

### All cases

The configuration can be set dynamicly, using the Roempro::Request constructor. *Useless if you set up Roempro::Config*

    request = Roempro::Request.new :url => "path_to_oempro", :username => "oempro_user", :password => "oempro_password"

Then, actually perform the request. For instance, retrieve all campaigns

    request.get_campaigns

**See the documentation for an advanced usage.**
