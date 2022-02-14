require_relative 'lib/isomorfeus/i18n/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-i18n'
  s.version      = Isomorfeus::I18n::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'https://isomorfeus.com'
  s.summary      = 'I18n for Isomorfeus.'
  s.description  = 'I18n for Isomorfeus.'
  s.metadata     = {
                     "github_repo" => "ssh://github.com/isomorfeus/gems",
                     "source_code_uri" => "https://github.com/isomorfeus/isomorfeus-project/isomorfeus-i18n"
                   }
  s.files        = `git ls-files -- lib LICENSE README.md`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 7.0.2'
  s.add_dependency 'fast_gettext', '~> 2.1.0'
  s.add_dependency 'http_accept_language', '~> 2.1.1'
  s.add_dependency 'oj', '~> 3.13.11'
  s.add_dependency 'opal', '~> 1.4.1'
  s.add_dependency 'opal-activesupport', '~> 0.3.3'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.14.10'
  s.add_dependency 'isomorfeus-preact', '~> 10.6.34'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.15'
  s.add_dependency 'isomorfeus-transport', Isomorfeus::I18n::VERSION
  s.add_dependency 'r18n-core', '~> 5.0.1'
  s.add_development_dependency 'isomorfeus', Isomorfeus::I18n::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.10.0'
end
