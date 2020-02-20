if %w[c con console].include?(ARGV[0])
  require 'pry'
  require_relative '../isomorfeus/console'

  Isomorfeus::Console.new.run
else
  require 'thor'
  require 'bundler'
  require 'fileutils'
  require 'erb'
  require 'active_support/core_ext/string'
  require 'opal-webpack-loader/installer_cli'
  require_relative '../isomorfeus/installer'
  require_relative '../isomorfeus/installer/rack_servers'
  require_relative '../isomorfeus/version'
  require_relative '../isomorfeus/installer/options_mangler'
  require_relative '../isomorfeus/installer/new_project'
  require_relative '../isomorfeus/cli'

  Isomorfeus::Installer.module_directories.each do |mod_dir|
    mod_path = File.realpath(File.join(Isomorfeus::Installer.base_path, mod_dir))
    modules = Dir.glob('*.rb', base: mod_path)
    modules.each do |mod|
      require_relative File.join(mod_path, mod)
    end
  end

  require_relative '../isomorfeus/cli'

  Isomorfeus::CLI.start(ARGV)
end
