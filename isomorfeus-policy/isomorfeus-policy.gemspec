require_relative 'lib/isomorfeus/policy/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-policy'
  s.version      = Isomorfeus::Policy::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'http://isomorfeus.com'
  s.summary      = 'Policies for Isomorfeus.'
  s.description  = 'Policies for Isomorfeus.'
  s.metadata     = { "github_repo" => "ssh://github.com/isomorfeus/gems" }
  s.files        = `git ls-files -- lib LICENSE README.md`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'opal', '>= 1.2.0'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.13.0'
  s.add_dependency 'isomorfeus-preact', '~> 10.5.7'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.6'
  s.add_development_dependency 'isomorfeus', Isomorfeus::Policy::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.8.0'
end
