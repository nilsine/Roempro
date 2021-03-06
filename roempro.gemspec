# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'roempro/version'

Gem::Specification.new do |gem|
  gem.name          = "roempro"
  gem.version       = Roempro::VERSION
  gem.authors       = ["Nilsine, Loïk Révillon, Jean-philippe Lannoy"]
  gem.email         = ["contact@revillon.dyndns.org, jp.lannoy@nilsine.fr"]
  gem.description   = "Deal with a given Oempro application API. Handle about subscribers, campaigns and emails"
  gem.summary       = "Ruby wrapper for Oempro API"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.has_rdoc      = true
end
