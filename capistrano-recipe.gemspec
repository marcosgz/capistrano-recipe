# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "capistrano/recipe/version"

Gem::Specification.new do |s|
  s.name        = "capistrano-recipe"
  s.version     = Capistrano::Recipe::VERSION
  s.authors     = ["Marcos G. Zimmermann"]
  s.email       = ["mgzmaster@gmail.com"]
  s.homepage    = "https://github.com/marcosgz/capistrano-recipe"
  s.summary     = %q{Capistrano recipe}

  s.rubyforge_project = "capistrano-recipe"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "capistrano", "~> 2.14.1"
  s.add_development_dependency "pry", "~> 0.9.11.4"
end
