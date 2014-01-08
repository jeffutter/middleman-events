# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-events"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeffery Utter"]
  s.email       = ["jeff@jeffutter.com"]
  # s.homepage    = "http://example.com"
  s.summary     = %q{Middleman extension to create event pages for artists/musicians}
  # s.description = %q{A longer description of your extension}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # The version of middleman-core your extension depends on
  s.add_runtime_dependency("middleman-core", [">= 3.2.1"])

  s.add_runtime_dependency("tzinfo",    ["~> 1.1.0"])
  s.add_runtime_dependency("timezone",  ["~> 0.3.1"])
  s.add_runtime_dependency("icalendar", ["~> 1.5.0"])
end
