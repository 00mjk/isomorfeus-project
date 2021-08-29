require_relative 'lib/isomorfeus/transport/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-transport'
  s.version      = Isomorfeus::Transport::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'http://isomorfeus.com'
  s.summary      = 'Various transport options for Isomorfeus.'
  s.description  = 'Various transport options for Isomorfeus.'
  s.metadata     = { "github_repo" => "ssh://github.com/isomorfeus/gems" }
  s.files        = `git ls-files -- lib LICENSE README.md`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 6.0'
  s.add_dependency 'bcrypt', '~> 3.1.13'
  s.add_dependency 'dbm'
  s.add_dependency 'iodine', '~> 0.7.38'
  s.add_dependency 'oj', '>= 3.10.0'
  s.add_dependency 'opal', '>= 1.0.0'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.1'
  s.add_dependency 'isomorfeus-react', '>= 16.13.11'
  s.add_dependency 'isomorfeus-policy', Isomorfeus::Transport::VERSION
  s.add_dependency 'sdbm', '~> 1.0.0'
  s.add_dependency 'sorted_set', '~> 1.0.3'
  s.add_development_dependency 'isomorfeus', Isomorfeus::Transport::VERSION
  s.add_development_dependency 'opal-webpack-loader', '>= 0.11.1'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.8.0'
end
