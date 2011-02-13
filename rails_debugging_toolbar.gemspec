# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rails_debugging_toolbar/version"

Gem::Specification.new do |s|
  s.name        = "rails_debugging_toolbar"
  s.version     = RailsDebuggingToolbar::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rob Hunter"]
  s.email       = ["rhunter@thoughtworks.com"]
  s.homepage    = ""
  s.summary     = %q{Use your browser to find which template rendered some HTML}
  s.description = %q{This tool helps you dig deeper through the Rails rendering stack using just your browser.}

  s.rubyforge_project = "rails_debugging_toolbar"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "actionpack", ">= 2.3.5", "< 4.0.0"
end
