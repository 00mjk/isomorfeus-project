require 'isomorfeus-transport'
require 'isomorfeus/data/config'
require 'isomorfeus/data/attribute_support'
require 'isomorfeus/data/generic_class_api'
require 'isomorfeus/data/generic_instance_api'
require 'isomorfeus/data/element_validator'

if RUBY_ENGINE == 'opal'
  require 'isomorfeus/data/reducer'
  Isomorfeus::Data::Reducer.add_reducer_to_store
  Isomorfeus.zeitwerk.push_dir('isomorfeus_data')
  require_tree 'isomorfeus_data', :autoload
  Isomorfeus.zeitwerk.push_dir('data')
else
  require 'uri'
  require 'oj'
  require 'active_support'
  require 'active_support/core_ext/hash'
  # require 'arango-driver'

  require 'isomorfeus_data/lucid_data/query_result'
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
  require 'isomorfeus_data/lucid_data/link_collection/mixin'
  require 'isomorfeus_data/lucid_data/link_collection/base'
  require 'isomorfeus_data/lucid_data/graph/finders'
  require 'isomorfeus_data/lucid_data/graph/mixin'
  require 'isomorfeus_data/lucid_data/graph/base'
  require 'isomorfeus_data/lucid_data/composition/mixin'
  require 'isomorfeus_data/lucid_data/composition/base'
  require 'isomorfeus_data/lucid_data/query/mixin'
  require 'isomorfeus_data/lucid_data/query/base'

  require 'isomorfeus_data/lucid_data/generic_collection'
  require 'isomorfeus_data/lucid_data/generic_edge'
  require 'isomorfeus_data/lucid_data/generic_edge_collection'
  require 'isomorfeus_data/lucid_data/generic_node'

  require 'isomorfeus/data/handler/generic'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  path = File.expand_path(File.join('app', 'data'))

  Isomorfeus.zeitwerk.push_dir(path)
end
