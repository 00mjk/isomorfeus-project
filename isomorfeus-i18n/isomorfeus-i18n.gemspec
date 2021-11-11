require_relative 'lib/isomorfeus/i18n/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-i18n'
  s.version      = Isomorfeus::I18n::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'http://isomorfeus.com'
  s.summary      = 'I18n for Isomorfeus.'
  s.description  = 'I18n for Isomorfeus.'
  s.metadata     = { "github_repo" => "ssh://github.com/isomorfeus/gems" }
  s.files        = `git ls-files -- lib LICENSE README.md`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 6.1'
  s.add_dependency 'fast_gettext', '~> 2.1.0'
  s.add_dependency 'http_accept_language', '~> 2.1.1'
  s.add_dependency 'oj', '~> 3.13.9'
  s.add_dependency 'opal', '~> 1.3.0'
  s.add_dependency 'opal-activesupport', '~> 0.3.3'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.13.3'
  s.add_dependency 'isomorfeus-preact', '~> 10.5.11'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.9'
  s.add_dependency 'isomorfeus-transport', Isomorfeus::I18n::VERSION
  s.add_dependency 'isomorfeus-data', Isomorfeus::I18n::VERSION
  s.add_development_dependency 'isomorfeus', Isomorfeus::I18n::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.8.0'
end
