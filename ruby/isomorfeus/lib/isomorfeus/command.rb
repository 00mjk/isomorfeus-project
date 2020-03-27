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
  require 'oj'
  require 'opal-webpack-loader/installer_cli'
  require_relative '../isomorfeus/version'
  require_relative '../isomorfeus/installer'
  require_relative '../isomorfeus/installer/rack_servers'
  require_relative '../isomorfeus/installer/options_mangler'
  require_relative '../isomorfeus/installer/dsl'
  require_relative '../isomorfeus/installer/gemfile'
  require_relative '../isomorfeus/installer/install_targets'
  require_relative '../isomorfeus/installer/new_project'
  require_relative '../isomorfeus/installer/test_app_files'
  require_relative '../isomorfeus/installer/upgrade'
  require_relative '../isomorfeus/installer/target/web'
  require_relative '../isomorfeus/installer/yarn_and_bundle'

  begin
    require 'isomorfeus/professional/version'
    if Isomorfeus::VERSION == Isomorfeus::Professional::VERSION
      require 'isomorfeus-professional-installer'
      Isomorfeus::Installer.is_professional = true
      puts "Thanks for purchasing Isomorfeus Professional."
    else
      Isomorfeus::Installer.is_professional = false
      STDERR.puts "Isomorfeus Professional not loaded, version mismatch Isomorfeus: #{Isomorfeus::VERSION} != Professional: #{Isomorfeus::Professional::VERSION}"
    end
  rescue LoadError
    Isomorfeus::Installer.is_professional = false
    puts "Isomorfeus Professional not available."
  end

  require_relative '../isomorfeus/cli'

  Isomorfeus::CLI.start(ARGV)
end
