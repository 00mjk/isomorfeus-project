require 'isomorfeus-transport'
require 'isomorfeus/operation/config'

if RUBY_ENGINE == 'opal'
  Isomorfeus.zeitwerk.push_dir('isomorfeus_operation')
  require_tree 'isomorfeus_operation', :autoload
  Isomorfeus.zeitwerk.push_dir('operations')
else
  require 'oj'
  require 'isomorfeus/operation/handler/operation_handler'
  require 'isomorfeus_operation/lucid_operation/gherkin'
  require 'isomorfeus_operation/lucid_operation/steps'
  require 'isomorfeus_operation/lucid_operation/promise_run'
  require 'isomorfeus_operation/lucid_local_operation/mixin'
  require 'isomorfeus_operation/lucid_local_operation/base'
  require 'isomorfeus_operation/lucid_quick_op/mixin'
  require 'isomorfeus_operation/lucid_quick_op/base'
  require 'isomorfeus_operation/lucid_operation/mixin'
  require 'isomorfeus_operation/lucid_operation/base'
  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  # require 'active_support/dependencies'

  path = File.expand_path(File.join('isomorfeus', 'operations'))

  Isomorfeus.zeitwerk.push_dir(path)
end
