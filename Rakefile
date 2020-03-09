require 'bundler'
require 'bundler/cli'
require 'bundler/cli/exec'

VERSION = File.read('ISOMORFEUS_VERSION').chop
puts "VERSION #{VERSION}"

task default: %w[ruby_specs]

task :ruby_specs do
  pwd = Dir.pwd
  Dir.chdir('ruby')
  system('rake')
  Dir.chdir(pwd)
end
