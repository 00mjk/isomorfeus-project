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

  s.files          = `git ls-files -- {lib,LICENSE,README.md}`.split("\n")
  # s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths  = ['lib']

  s.add_dependency 'activesupport', '~> 5.2'
  s.add_dependency 'iodine', '~> 0.7.33'
  s.add_dependency 'oj', '>= 3.6'
  s.add_dependency 'opal', '>= 0.11.0'
  s.add_dependency 'isomorfeus-redux', '~> 4.0.8'
  s.add_dependency 'isomorfeus-react', '~> 16.8.9'
  s.add_dependency 'websocket-driver', '~> 0.7.0'
end