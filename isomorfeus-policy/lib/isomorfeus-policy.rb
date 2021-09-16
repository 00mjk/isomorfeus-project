require 'isomorfeus-preact'
require 'isomorfeus/policy/config'
require 'lucid_props'

if RUBY_ENGINE == 'opal'
  Isomorfeus.zeitwerk.push_dir('isomorfeus_policy')
  require_tree 'isomorfeus_policy', autoload: true
  Isomorfeus.zeitwerk.push_dir('policies')
else
  require 'isomorfeus_policy/lucid_policy/exception'
  require 'isomorfeus_policy/lucid_policy/helper'
  require 'isomorfeus_policy/lucid_policy/mixin'
  require 'isomorfeus_policy/lucid_policy/base'
  require 'isomorfeus_policy/lucid_authorization/mixin'
  require 'isomorfeus_policy/lucid_authorization/base'
  require 'isomorfeus_policy/anonymous'
  require 'iso_opal'

  Opal.append_path(__dir__.untaint) unless IsoOpal.paths_include?(__dir__.untaint)
  path = File.expand_path(File.join('app', 'policies'))
  Isomorfeus.zeitwerk.push_dir(path) if Dir.exist?(path)
end
