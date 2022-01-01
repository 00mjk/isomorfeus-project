if %w[c con console].include?(ARGV[0])
  require 'pry'
  require_relative '../isomorfeus/console'

  Isomorfeus::Console.new.run
else
  require 'thor'
  require 'bundler'
  require 'fileutils'
  require 'erb'
  require 'active_support/isolated_execution_state'
  require 'active_support/core_ext/string'
  require 'oj'
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
  require_relative '../isomorfeus/installer/bundle'

  require_relative '../isomorfeus/cli'

  Isomorfeus::CLI.start(ARGV)
end
