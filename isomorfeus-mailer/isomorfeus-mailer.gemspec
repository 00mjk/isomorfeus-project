require_relative 'lib/isomorfeus/mailer/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-mailer'
  s.version      = Isomorfeus::Mailer::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'http://isomorfeus.com'
  s.summary      = 'Write mail template components and send mail.'
  s.description  = 'Write mail template components and send mail.'
  s.metadata     = { "github_repo" => "ssh://github.com/isomorfeus/gems" }
  s.files        = `git ls-files -- lib LICENSE README.md`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 7.0.1'
  s.add_dependency 'mailhandler', '~> 1.0.59'
  s.add_dependency 'net-imap', '~> 0.2.2'
  s.add_dependency 'net-smtp', '~> 0.3.1'
  s.add_dependency 'nokogiri', '~> 1.12.5'
  s.add_dependency 'oj', '~> 3.13.11'
  s.add_dependency 'opal', '~> 1.4.1'
  s.add_dependency 'opal-activesupport', '~> 0.3.3'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.14.5'
  s.add_dependency 'isomorfeus-preact', '~> 10.6.7'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.11'
  s.add_dependency 'isomorfeus-transport', Isomorfeus::Mailer::VERSION
  s.add_development_dependency 'isomorfeus', Isomorfeus::Mailer::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.10.0'
  s.add_development_dependency 'rspec-collection_matchers', '~> 1.2.0'
end
