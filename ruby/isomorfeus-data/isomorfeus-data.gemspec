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
  s.files        = `git ls-files -- lib LICENSE README.md`.split("\n")
  # s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 6.0'
  s.add_dependency 'arango-driver', '~> 3.5.0.alpha1'
  s.add_dependency 'oj', '>= 3.10.0'
  s.add_dependency 'opal', '>= 1.0.0'
  s.add_dependency 'opal-activesupport', '~> 0.3.3'
  s.add_dependency 'isomorfeus-react', '>= 16.12.14'
  s.add_dependency 'isomorfeus-redux', '~> 4.0.17'
  s.add_dependency 'isomorfeus-transport', Isomorfeus::Data::VERSION
  s.add_development_dependency 'isomorfeus', Isomorfeus::Data::VERSION
  s.add_development_dependency 'opal-webpack-loader', '>= 0.9.10'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.8.0'
end
