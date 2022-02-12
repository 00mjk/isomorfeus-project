require_relative 'lib/isomorfeus/data/version.rb'

Gem::Specification.new do |s|
  s.name         = 'isomorfeus-data'
  s.version      = Isomorfeus::Data::VERSION
  s.author       = 'Jan Biedermann'
  s.email        = 'jan@kursator.de'
  s.license      = 'MIT'
  s.homepage     = 'https://isomorfeus.com'
  s.summary      = 'Reactive objects, documents, files and queries for isomorfeus.'
  s.description  = "Develop apps with powerful reactive data access and queries."
  s.metadata     = {
                     "github_repo" => "ssh://github.com/isomorfeus/gems",
                     "source_code_uri" => "https://github.com/isomorfeus/isomorfeus-project/isomorfeus-data"
                   }
  s.files        = `git ls-files -- lib opal LICENSE README.md`.split("\n")
  # s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '~> 7.0.2'
  s.add_dependency 'oj', '~> 3.13.11'
  s.add_dependency 'opal', '~> 1.4.1'
  s.add_dependency 'opal-activesupport', '~> 0.3.3'
  s.add_dependency 'isomorfeus-asset-manager', '~> 0.14.9'
  s.add_dependency 'isomorfeus-ferret', '~> 0.12.6'
  s.add_dependency 'isomorfeus-hamster', '~> 0.6.4'
  s.add_dependency 'isomorfeus-preact', '~> 10.6.31'
  s.add_dependency 'isomorfeus-redux', '~> 4.1.15'
  s.add_dependency 'isomorfeus-transport', Isomorfeus::Data::VERSION
  s.add_development_dependency 'isomorfeus', Isomorfeus::Data::VERSION
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.10.0'
end
