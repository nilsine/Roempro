# Roempro - Oempro Ruby Wrapper

The purpose of this gem is to provide a way to handle the API of a given oempro application.

## Installation

Add this line to your application's Gemfile:

    gem 'roempro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install roempro

## Usage

### Rails 3

1. Set up the configuration (see config/initializers/roempro.rb)
2. Use it in your code.

### Ruby and others frameworks

The informations can be submit to a new Roempro::Request object.

	roempro = Roempro::Request.new :host => "localhost", :user => "Leeroy", :password => "nvmb3r5&ch4r4ct3r5"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
