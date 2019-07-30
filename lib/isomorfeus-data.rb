require 'opal'
require 'opal-autoloader'
require 'opal-activesupport'
require 'isomorfeus-redux'
require 'isomorfeus-transport'

require 'isomorfeus/data/config'
require 'isomorfeus/data/props'
require 'isomorfeus/data/prop_declaration'
require 'lucid_node/mixin'
require 'lucid_node/base'
require 'lucid_edge/mixin'
require 'lucid_edge/base'
require 'lucid_array/mixin'
require 'lucid_array/base'
require 'lucid_collection/mixin'
require 'lucid_collection/base'
require 'lucid_graph/mixin'
require 'lucid_graph/base'
require 'lucid_hash/mixin'
require 'lucid_hash/base'

if RUBY_ENGINE == 'opal'
  require 'isomorfeus/data/core_ext/hash/deep_merge'
  require 'isomorfeus/data/reducer'
  Isomorfeus::Data::Reducer.add_reducer_to_store
  Opal::Autoloader.add_load_path('data')
else
  require 'active_support'
  require 'active_support/core_ext/hash'
  require 'isomorfeus/data/handler/array_load_handler'
  require 'isomorfeus/data/handler/collection_load_handler'
  require 'isomorfeus/data/handler/graph_load_handler'
  require 'isomorfeus/data/handler/hash_load_handler'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  require 'active_support/dependencies'

  path = if Dir.exist?(File.join('app', 'isomorfeus'))
           File.expand_path(File.join('app', 'isomorfeus', 'data'))
         elsif Dir.exist?(File.join('isomorfeus'))
           File.expand_path(File.join('isomorfeus', 'data'))
         end
  ActiveSupport::Dependencies.autoload_paths << path if path
  # we also need to require them all, so classes are registered accordingly
  Dir.glob("#{path}/**/*.rb").each do |file|
    require file
  end
end
