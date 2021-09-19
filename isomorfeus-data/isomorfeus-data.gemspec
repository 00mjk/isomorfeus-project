require_relative 'lib/isomorfeus/data/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-data'
  s.version      = Isomorfeus::Data::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'http://isomorfeus.com'
  s.summary      = 'Compose Graphs and Collections of data just as needed for a isomorfeus app.'
  s.description  = "Write Browser Apps that transparently access server side data with Graphs and Collections with ease."
  s.metadata     = { "github_repo" => "ssh://github.com/isomorfeus/gems" }
  s.files        = `git ls-files -- lib opal LICENSE README.md`.split("\n")
  # s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 6.0'
  s.add_dependency 'data_uri', '~> 0.1.0'
  s.add_dependency 'oj', '~> 3.13.7'
  s.add_dependency 'opal', '>= 1.2.0'
  s.add_dependency 'opal-activesupport', '~> 0.3.3'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.12.8'
  s.add_dependency 'isomorfeus-preact', '~> 10.5.7'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.6'
  s.add_dependency 'isomorfeus-transport', Isomorfeus::Data::VERSION
  s.add_development_dependency 'isomorfeus', Isomorfeus::Data::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.8.0'
end