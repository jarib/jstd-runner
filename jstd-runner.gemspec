# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jstd-runner/version"

Gem::Specification.new do |s|
  s.name        = "jstd-runner"
  s.version     = JstdRunner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jari Bakken"]
  s.email       = ["jari.bakken@gmail.com"]
  s.homepage    = "http://github.com/jarib/jstd-runner"
  s.summary     = %q{JsTestDriver wrapper}
  s.description = %q{Runs a JsTestDriver server + browsers with some built-in monitoring}

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'

  s.add_dependency "selenium-webdriver", "0.1.0"
  s.add_dependency "eventmachine", "0.12.10"
  s.add_dependency "mail", "2.2.10"
  s.add_dependency "daemons", "1.1.0"

  s.add_development_dependency "rspec", ">= 2.0.0"
end
