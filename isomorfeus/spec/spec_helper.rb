require 'bundler'
require 'cowsay'
require 'fileutils'
require 'oj'
require 'thor'
require 'erb'
require 'active_support/core_ext/string'
require 'thor'
require 'opal-webpack-loader/installer_cli'
require_relative '../lib/isomorfeus/version'
require_relative '../lib/isomorfeus/installer'
require_relative '../lib/isomorfeus/installer/rack_servers'
require_relative '../lib/isomorfeus/installer/options_mangler'
require_relative '../lib/isomorfeus/installer/dsl'
require_relative '../lib/isomorfeus/installer/gemfile'
require_relative '../lib/isomorfeus/installer/install_targets'
require_relative '../lib/isomorfeus/installer/new_project'
require_relative '../lib/isomorfeus/installer/test_app_files'
require_relative '../lib/isomorfeus/installer/upgrade'
require_relative '../lib/isomorfeus/installer/target/web'
require_relative '../lib/isomorfeus/installer/bundle'

require_relative '../lib/isomorfeus/cli'

puts Cowsay.say "Testing ISOMORFEUS INSTALLER. NO chance for bugs!", "Ghostbusters"
