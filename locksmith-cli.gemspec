# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "locksmith-cli/version"

Gem::Specification.new do |spec|
  spec.name          = "locksmith-cli"
  spec.version       = Locksmith::CLI::VERSION
  spec.authors       = ["Sentia MPC", "Thomas A. de Ruiter"]
  spec.email         = "thomas.de.ruiter@sentia.com"
  spec.summary       = "Locksmith CLI"
  spec.description   = "Quickly assume IAM Roles"
  spec.homepage      = "https://bitbucket.org/unitt/locksmith-cli"
  spec.required_ruby_version = ">= 2.2.0"
  spec.license       = "proprietary"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/(?:test|spec|features)/)
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "aws-sdk"
  spec.add_runtime_dependency "dotenv"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "tty-prompt"
  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "launchy"

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "rspec-given"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop-junit-formatter"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
end
