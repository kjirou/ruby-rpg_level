# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rpg_level/version'

Gem::Specification.new do |spec|
  spec.name          = "rpg_level"
  spec.version       = RpgLevel::VERSION
  spec.authors       = ["kjirou"]
  spec.email         = ["sorenariblog@gmail.com"]

  spec.summary       = 'Manage experience points with levels.'
  spec.description   = 'Manage experience points with levels.'
  spec.homepage      = 'https://github.com/kjirou/ruby-rpg_level'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
