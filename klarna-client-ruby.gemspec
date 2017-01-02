# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'klarna/version'

Gem::Specification.new do |gem|
  gem.name          = "klarna-client-ruby"
  gem.version       = Klarna::VERSION
  gem.authors       = ["Daniel Salmeron Amselem"]
  gem.email         = ["daniel.amselem@klarna.com"]
  gem.description   = %q{XMLRPC Client to Klarna's API.}
  gem.summary       = %q{XMLRPC Client to Klarna's API.}
  gem.homepage      = ""

  gem.add_development_dependency "activesupport", "~> 4.0"
  gem.add_development_dependency "byebug"
  gem.add_development_dependency "dotenv"
  gem.add_development_dependency "factory_girl"
  gem.add_development_dependency "fuubar"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock"

  gem.add_runtime_dependency "faraday_middleware"
  gem.add_runtime_dependency "gene_pool"
  gem.add_runtime_dependency "klarna_correlation_id"
  gem.add_runtime_dependency "retryable", '>= 2.0.0'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
