# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fn/salesforce/version'

Gem::Specification.new do |spec|
  spec.name          = "fn-salesforce"
  spec.version       = Fn::Salesforce::VERSION
  spec.authors       = ["Stuart Corbishley"]
  spec.email         = ["corbish@gmail.com"]

  spec.summary       = %q{Salesforce support adaptor for OpenFn}
  spec.description = <<-EOF
    CLI Tool and Adaptor for working with Salesforce.

    Intended to be used in conjunction with OpenFn, but has been designed
    with standalone use in mind.

    Leveraging JSON-Schema, fn-salesforce acts as a bridge between Salesforce
    and external data. It supports nested JSON data, and can resolve
    basic dependency graphs while providing access to intermediary data
    formats.
  EOF
  spec.homepage      = "https://github.com/stuartc/fn-salesforce"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = [ "fn-salesforce" ]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake-notes"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_dependency "restforce", "~> 2.1.0"
  spec.add_dependency "jsonpath", "~> 0.5.7"
  spec.add_dependency "hana", "~> 1.3.1"
  spec.add_dependency "virtus", "~> 1.0.5"
end
