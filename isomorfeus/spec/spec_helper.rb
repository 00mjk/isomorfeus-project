require 'bundler'
require 'cowsay'
require 'fileutils'
require 'oj'
require 'thor'
require 'erb'
require 'active_support/core_ext/string'
require 'thor'
require 'opal-webpack-loader/installer_cli'
require_relative '../lib/isomorfeus/installer'
require_relative '../lib/isomorfeus/installer/rack_servers'
require_relative '../lib/isomorfeus/installer/options_mangler'
require_relative '../lib/isomorfeus/installer/new_project'

Isomorfeus::Installer.module_directories.each do |mod_dir|
  mod_path = File.realpath(File.join(Isomorfeus::Installer.base_path, mod_dir))
  modules = Dir.glob('*.rb', base: mod_path)
  modules.each do |mod|
    require_relative File.join(mod_path, mod)
  end
end

require_relative '../lib/isomorfeus/cli'

puts Cowsay.say "Testing ISOMORFEUS INSTALLER. NO chance for bugs!", "Ghostbusters"
