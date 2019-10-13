require 'isomorfeus-transport'
require 'isomorfeus/data/config'
require 'isomorfeus/data/props'
require 'lucid_edge/mixin'
require 'lucid_edge/base'
require 'lucid_document/mixin'
require 'lucid_document/base'
require 'lucid_document_collection/mixin'
require 'lucid_document_collection/base'
require 'lucid_edge_collection/mixin'
require 'lucid_edge_collection/base'
require 'lucid_graph/mixin'
require 'lucid_graph/base'
require 'lucid_composable_graph/mixin'
require 'lucid_composable_graph/base'

if RUBY_ENGINE == 'opal'
  require 'isomorfeus/data/reducer'
  Isomorfeus::Data::Reducer.add_reducer_to_store
  Opal::Autoloader.add_load_path('data')
else
  require 'oj'
  require 'active_support'
  require 'active_support/core_ext/hash'
  require 'arango-driver'
  require 'lucid_generic_document/mixin'
  require 'lucid_generic_document/base'
  require 'lucid_generic_edge/mixin'
  require 'lucid_generic_edge/base'
  require 'lucid_generic_collection/mixin'
  require 'lucid_generic_collection/base'
  require 'lucid_composable_graph/mixin'
  require 'lucid_composable_graph/base'
  require 'isomorfeus/data/handler/arango'
  require 'isomorfeus/data/handler/generic'
  require 'isomorfeus/data/handler/object_call'
  require 'isomorfeus/data/handler/object_store'
  require 'lucid_storable_object/mixin'
  require 'lucid_storable_object/base'
  require 'lucid_remote_object/mixin'
  require 'lucid_remote_object/base'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  path = File.expand_path(File.join('isomorfeus', 'data'))

  Isomorfeus.zeitwerk.push_dir(path)
end
