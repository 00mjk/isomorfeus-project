require 'isomorfeus-transport'
require 'isomorfeus/operation/config'
require 'isomorfeus/operation/gherkin'
require 'isomorfeus/operation/mixin'
require 'isomorfeus/operation/promise_run'
require 'lucid_local_operation/mixin'
require 'lucid_local_operation/base'
require 'lucid_quick_op/mixin'
require 'lucid_quick_op/base'
require 'lucid_operation/mixin'
require 'lucid_operation/base'

if RUBY_ENGINE == 'opal'
  Isomorfeus.zeitwerk.push_dir('operations')
else
  require 'oj'
  require 'isomorfeus/operation/handler/operation_handler'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  # require 'active_support/dependencies'

  path = File.expand_path(File.join('isomorfeus', 'operations'))

  Isomorfeus.zeitwerk.push_dir(path)
end
