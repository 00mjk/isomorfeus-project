require_relative 'lib/isomorfeus/transport/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-transport'
  s.version      = Isomorfeus::Transport::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'https://isomorfeus.com'
  s.summary      = 'Channels, authetication and various transport options for Isomorfeus.'
  s.description  = 'Channels, authetication and various transport options for Isomorfeus.'
  s.metadata     = {
                     "github_repo" => "ssh://github.com/isomorfeus/gems",
                     "source_code_uri" => "https://github.com/isomorfeus/isomorfeus-project/isomorfeus-transport"
                   }
  s.files        = `git ls-files -- lib LICENSE README.md node_modules package.json`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 7.0.2'
  s.add_dependency 'bcrypt', '~> 3.1.16'
  s.add_dependency 'brotli', '~> 0.4.0'
  s.add_dependency 'isomorfeus-iodine', '~> 0.7.47'
  s.add_dependency 'oj', '~> 3.13.11'
  s.add_dependency 'opal', '~> 1.4.1'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.14.17'
  s.add_dependency 'isomorfeus-hamster', '~> 0.6.6'
  s.add_dependency 'isomorfeus-preact', '~> 10.6.50'
  s.add_dependency 'isomorfeus-policy', Isomorfeus::Transport::VERSION
  s.add_dependency 'isomorfeus-redux', '~> 4.1.18'
  s.add_dependency 'isomorfeus-speednode', '~> 0.5.2'
  s.add_dependency 'rack', '~> 2.2.3'
  s.add_dependency 'sorted_set', '~> 1.0.3'
  s.add_dependency 'zlib', '~> 2.1.1'
  s.add_development_dependency 'isomorfeus', Isomorfeus::Transport::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.11.0'
end
