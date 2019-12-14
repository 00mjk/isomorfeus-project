require 'isomorfeus-transport'
require 'isomorfeus/data/config'
require 'isomorfeus/data/props'
require 'isomorfeus/data/attribute_support'
require 'isomorfeus/data/generic_class_api'
require 'isomorfeus/data/generic_instance_api'
require 'isomorfeus/data/element_validator'
#require 'lucid_arango/node/mixin'
#require 'lucid_arango/node/base'
#require 'lucid_arango/document/mixin'
#require 'lucid_arango/document/base'
#require 'lucid_arango/vertex/mixin'
#require 'lucid_arango/vertex/base'
#require 'lucid_arango/edge/mixin'
#require 'lucid_arango/edge/base'
#require 'lucid_arango/collection/mixin'
#require 'lucid_arango/collection/base'
#require 'lucid_arango/edge_collection/mixin'
#require 'lucid_arango/edge_collection/base'
#require 'lucid_arango/graph/mixin'
#require 'lucid_arango/graph/base'


if RUBY_ENGINE == 'opal'
  require 'isomorfeus/data/reducer'
  Isomorfeus::Data::Reducer.add_reducer_to_store
  require_tree 'isomorfeus_data', :autoload
  Isomorfeus.zeitwerk.push_dir('isomorfeus_data')
  Isomorfeus.zeitwerk.push_dir('data')
else
  require 'oj'
  require 'active_support'
  require 'active_support/core_ext/hash'
  #require 'arango-driver'
  #require 'isomorfeus/data/handler/arango'

  require 'isomorfeus_data/lucid_data/array/mixin'
  require 'isomorfeus_data/lucid_data/array/base'
  require 'isomorfeus_data/lucid_data/hash/mixin'
  require 'isomorfeus_data/lucid_data/hash/base'
  require 'isomorfeus_data/lucid_data/node/mixin'
  require 'isomorfeus_data/lucid_data/node/base'
  require 'isomorfeus_data/lucid_data/document/mixin'
  require 'isomorfeus_data/lucid_data/document/base'
  require 'isomorfeus_data/lucid_data/vertex/mixin'
  require 'isomorfeus_data/lucid_data/vertex/base'
  require 'isomorfeus_data/lucid_data/edge/mixin'
  require 'isomorfeus_data/lucid_data/edge/base'
  require 'isomorfeus_data/lucid_data/link/mixin'
  require 'isomorfeus_data/lucid_data/link/base'
  require 'isomorfeus_data/lucid_data/collection/finders'
  require 'isomorfeus_data/lucid_data/collection/mixin'
  require 'isomorfeus_data/lucid_data/collection/base'
  require 'isomorfeus_data/lucid_data/edge_collection/finders'
  require 'isomorfeus_data/lucid_data/edge_collection/mixin'
  require 'isomorfeus_data/lucid_data/edge_collection/base'
  require 'isomorfeus_data/lucid_data/graph/finders'
  require 'isomorfeus_data/lucid_data/graph/mixin'
  require 'isomorfeus_data/lucid_data/graph/base'
  require 'isomorfeus_data/lucid_data/object/mixin'
  require 'isomorfeus_data/lucid_data/object/base'
  require 'isomorfeus_data/lucid_data/remote_object/mixin'
  require 'isomorfeus_data/lucid_data/remote_object/base'
  require 'isomorfeus_data/lucid_data/composition/mixin'
  require 'isomorfeus_data/lucid_data/composition/base'

  require 'isomorfeus/data/handler/generic'
  require 'isomorfeus/data/handler/object_call'
  require 'isomorfeus/data/handler/object_store'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  path = File.expand_path(File.join('isomorfeus', 'data'))

  Isomorfeus.zeitwerk.push_dir(path)
end
