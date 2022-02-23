require_relative 'lib/isomorfeus/operation/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-operation'
  s.version      = Isomorfeus::Operation::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'https://isomorfeus.com'
  s.summary      = 'Natural language operations for Isomorfeus.'
  s.description  = 'Write operations for Isomorfeus in your natural language.'
  s.metadata     = {
                     "github_repo" => "ssh://github.com/isomorfeus/gems",
                     "source_code_uri" => "https://github.com/isomorfeus/isomorfeus-project/isomorfeus-operation"
                   }
  s.files        = `git ls-files -- lib LICENSE README.md`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 7.0.2'
  s.add_dependency 'oj', '~> 3.13.11'
  s.add_dependency 'opal', '~> 1.4.1'
  s.add_dependency 'opal-activesupport', '~> 0.3.3'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.14.17'
  s.add_dependency 'isomorfeus-policy', Isomorfeus::Operation::VERSION
  s.add_dependency 'isomorfeus-preact', '~> 10.6.49'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.18'
  s.add_dependency 'isomorfeus-transport', Isomorfeus::Operation::VERSION
  s.add_development_dependency 'isomorfeus', Isomorfeus::Operation::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.11.0'
end
