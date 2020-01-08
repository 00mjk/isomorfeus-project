require_relative 'lib/isomorfeus/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus'
  s.version      = Isomorfeus::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'http://isomorfeus.com'
  s.summary      = 'Create new isomorfeus-project applications with ease.'
  s.description  = 'Create new isomorfeus-project applications with ease.'
  s.metadata     = { "github_repo" => "ssh://github.com/isomorfeus/gems" }
  s.bindir       = 'bin'
  s.executables  << 'isomorfeus'
  s.executables  << 'yandle'
  s.files        = `git ls-files -- {lib,LICENSE,readme.md}`.split("\n")
  # s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 6.0'
  s.add_dependency 'bundler'
  s.add_dependency 'oj', '>= 3.10.0'
  s.add_dependency 'pry', '~> 0.12.2'
  s.add_dependency 'opal-webpack-loader', '>= 0.9.10'
  s.add_dependency 'thor', '>= 0.19.4'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.8.0'
end
