require 'bundler/cli'
require 'bundler/cli/exec'

task default: %w[ruby_specs]

task :ruby_specs do
  Rake::Task['ruby_installer_spec'].invoke
end

task :ruby_installer_spec do
  pwd = Dir.pwd
  Dir.chdir(File.join('ruby', 'isomorfeus-installer'))
  puts `bundle install`
  options = { keep_file_descriptors: false }
  options.define_singleton_method(:keep_file_descriptors?) do
    false
  end
  Bundler::CLI::Exec.new(options, ['rspec']).run
  Dir.chdir(pwd)
end

