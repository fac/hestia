# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hestia/version'

Gem::Specification.new do |spec|
  spec.name          = "hestia"
  spec.version       = Hestia::VERSION
  spec.authors       = ["Caius Durling"]
  spec.email         = ["caius@freeagent.com"]
  spec.summary       = %{Support for deprecating/rotating signed cookie secret tokens in rails}
  spec.homepage      = "https://github.com/fac/hestia"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_dependency = "~> 3.2.21"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
