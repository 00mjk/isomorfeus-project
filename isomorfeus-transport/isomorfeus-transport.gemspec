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
  s.files        = `git ls-files -- lib LICENSE README.md node_modules package.json`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 6.1'
  s.add_dependency 'bcrypt', '~> 3.1.16'
  s.add_dependency 'isomorfeus-iodine', '~> 0.7.45'
  s.add_dependency 'oj', '~> 3.13.9'
  s.add_dependency 'opal', '~> 1.3.2'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.14.0'
  s.add_dependency 'isomorfeus-hamster', '~> 0.6.1'
  s.add_dependency 'isomorfeus-preact', '~> 10.6.0'
  s.add_dependency 'isomorfeus-policy', Isomorfeus::Transport::VERSION
  s.add_dependency 'isomorfeus-redux', '~> 4.1.9'
  s.add_dependency 'sorted_set', '~> 1.0.3'
  s.add_development_dependency 'isomorfeus', Isomorfeus::Transport::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.10.0'
end
