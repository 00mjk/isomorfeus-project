require 'isomorfeus-react'
require 'isomorfeus/policy/config'

if RUBY_ENGINE == 'opal'
  Isomorfeus.zeitwerk.push_dir('isomorfeus_policy')
  require_tree 'isomorfeus_policy', :autoload
  Isomorfeus.zeitwerk.push_dir('policies')
else
  require 'isomorfeus_policy/lucid_policy/exception'
  require 'isomorfeus_policy/lucid_policy/helper'
  require 'isomorfeus_policy/lucid_policy/mixin'
  require 'isomorfeus_policy/lucid_policy/base'
  require 'isomorfeus_policy/lucid_authorization/mixin'
  require 'isomorfeus_policy/lucid_authorization/base'
  require 'isomorfeus_policy/anonymous'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)
  path = File.expand_path(File.join('isomorfeus', 'policies'))
  Isomorfeus.zeitwerk.push_dir(path)
end
