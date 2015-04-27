# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mini_node/version"

Gem::Specification.new do |spec|
  spec.name          = "mini_node"
  spec.version       = MiniNode::VERSION
  spec.authors       = ["Rodrigo Navarro"]
  spec.email         = ["rnavarro@rnavarro.com.br"]

  spec.summary       = "Simple reactor pattern implementation in pure Ruby."
  spec.description   = "This library was implemented during a training session, it is not production ready."
  spec.homepage      = "https://github.com/reu/mini_node"

  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(/^spec/) }
  spec.require_paths = ["lib"]

  spec.add_dependency "http_parser.rb", "~> 0.6"
  spec.add_dependency "mime-types", "~> 2.4"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
