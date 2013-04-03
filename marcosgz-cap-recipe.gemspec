# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "marcosgz-cap-recipe"
  s.version     = "0.0.9"
  s.authors     = ["Marcos G. Zimmermann"]
  s.email       = ["mgzmaster@gmail.com"]
  s.homepage    = "https://github.com/marcosgz/capistrano-recipe"
  s.summary     = %q{Capistrano recipe}

  s.rubyforge_project = "capistrano-recipe"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "capistrano", "> 2.0.0"
  s.add_dependency "marcosgz-cap-template", "~> 0.0.3"
end
