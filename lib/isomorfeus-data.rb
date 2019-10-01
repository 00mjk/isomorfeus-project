require 'opal'
require 'opal-autoloader'
require 'opal-activesupport'
require 'isomorfeus-redux'
require 'isomorfeus-react'
require 'isomorfeus-transport'

require 'isomorfeus/data/config'
require 'isomorfeus/data/props'
require 'lucid_storable_object/mixin'
require 'lucid_storable_object/base'
require 'lucid_generic_collection/mixin'
require 'lucid_generic_collection/base'

if RUBY_ENGINE == 'opal'
  require 'isomorfeus/data/reducer'
  Isomorfeus::Data::Reducer.add_reducer_to_store
  Opal::Autoloader.add_load_path('data')
else
  require 'oj'
  require 'active_support'
  require 'active_support/core_ext/hash'
  require 'arango-driver'
  require 'lucid_generic_node/mixin'
  require 'lucid_generic_node/base'
  require 'lucid_generic_edge/mixin'
  require 'lucid_generic_edge/base'
  require 'lucid_generic_graph/mixin'
  require 'lucid_generic_graph/base'
  require 'isomorfeus/data/handler/object'
  require 'isomorfeus/data/handler/generic'
  require 'isomorfeus/data/handler/arango'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  require 'active_support/dependencies'

  path = File.expand_path(File.join('isomorfeus', 'data'))

  ActiveSupport::Dependencies.autoload_paths << path
  # we also need to require them all, so classes are registered accordingly
  Dir.glob("#{path}/**/*.rb").each do |file|
    require file
  end
end
