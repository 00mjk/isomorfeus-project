require '../version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-transport'
  s.version      = Isomorfeus::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.homepage     = 'http://isomorfeus.com'
  s.summary      = 'Various client side transport options for Isomorfeus.'
  s.description  = 'Various client side transport options for Isomorfeus.'

  s.files          = `git ls-files -- {lib,LICENSE,readme.md}`.split("\n")
  # s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths  = ['lib']

  s.add_dependency 'oj', '>= 3.6'
  s.add_dependency 'opal', '>= 0.11.0'
  s.add_runtime_dependency 'activesupport', '~> 5.0'
  s.add_runtime_dependency 'websocket-driver', '~> 0.7.0'
  s.add_runtime_dependency 'isomorfeus-redux', '~> 4.0.7'
  s.add_runtime_dependency 'isomorfeus-react', '~> 16.8.5'
end