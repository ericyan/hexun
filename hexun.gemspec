# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hexun/version'

Gem::Specification.new do |spec|
  spec.name          = "hexun"
  spec.version       = Hexun::VERSION
  spec.authors       = ["Eric Yan"]
  spec.email         = ["long@ericyan.me"]
  spec.description   = %q{A simple wrapper for Hexun's undocumented fund data API.}
  spec.summary       = %q{Extract fund data from Hexun}
  spec.homepage      = "https://github.com/ericyan/hexun"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
