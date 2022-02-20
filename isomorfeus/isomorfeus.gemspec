require_relative 'lib/isomorfeus/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus'
  s.version      = Isomorfeus::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'https://isomorfeus.com'
  s.summary      = 'Command line utilities and installer for isomorfeus projects.'
  s.description  = 'Command line utilities and installer for isomorfeus projects.'
  s.metadata     = {
                     "github_repo" => "ssh://github.com/isomorfeus/gems",
                     "source_code_uri" => "https://github.com/isomorfeus/isomorfeus-project/isomorfeus"
                   }
  s.bindir       = 'bin'
  s.executables  << 'isomorfeus'
  s.executables  << 'ismos'
  s.files        = `git ls-files -- lib LICENSE README.md`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 7.0.2'
  s.add_dependency 'bundler'
  s.add_dependency 'oj', '~> 3.13.11'
  s.add_dependency 'pry', '~> 0.14.1'
  s.add_dependency 'thor', '>= 0.19.4'
  s.add_dependency 'isomorfeus-speednode', '~> 0.5.2'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.14.17'
  s.add_dependency 'isomorfeus-preact', '~> 10.6.40'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.18'
  s.add_dependency 'isomorfeus-policy', Isomorfeus::VERSION
  s.add_dependency 'isomorfeus-transport', Isomorfeus::VERSION
  s.add_dependency 'isomorfeus-data', Isomorfeus::VERSION
  s.add_dependency 'isomorfeus-i18n', Isomorfeus::VERSION
  s.add_dependency 'isomorfeus-operation', Isomorfeus::VERSION
  s.add_dependency 'isomorfeus-mailer', Isomorfeus::VERSION

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.11.0'
end
