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

  s.add_dependency 'opal', '~> 1.4.1'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.14.5'
  s.add_dependency 'isomorfeus-preact', '~> 10.6.11'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.11'
  s.add_development_dependency 'isomorfeus', Isomorfeus::Policy::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.10.0'
end
