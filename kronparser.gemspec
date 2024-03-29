# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kronparser/version"

Gem::Specification.new do |s|
  s.name        = "kronparser"
  s.version     = KronParser::VERSION
  s.authors     = ["mechamogera"]
  s.email       = [""]
  s.homepage    = "https://github.com/mechamogera/kronparser"
  s.summary     = %q{datermine next scheduled crontab run}
  s.description = %q{datermine next scheduled crontab run}

  s.rubyforge_project = "kronparser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
   s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
