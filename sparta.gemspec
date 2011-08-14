# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sparta/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["José Valim", "Yehuda Katz"]
  gem.email         = ["jose.valim@gmail.com", "wycats@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "sparta"
  gem.require_paths = ["lib"]
  gem.version       = Thrasos::VERSION

  gem.add_dependency "rkelly"
  gem.add_development_dependency "rspec"
end
