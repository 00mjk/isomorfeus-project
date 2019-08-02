require 'opal'
require 'opal-autoloader'
require 'opal-activesupport'
require 'isomorfeus-redux'
require 'isomorfeus-transport'
require 'isomorfeus/operation/config'
require 'isomorfeus/operation/gherkin'
require 'isomorfeus/operation/mixin'
require 'lucid_local_operation/mixin'
require 'lucid_local_operation/base'
require 'lucid_quick_op/mixin'
require 'lucid_quick_op/base'
require 'lucid_operation/mixin'
require 'lucid_operation/base'

if RUBY_ENGINE == 'opal'
  Opal::Autoloader.add_load_path('data')
else
  require 'oj'
  require 'isomorfeus/operation/handler/operation_handler'

  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  require 'active_support/dependencies'

  path = if Dir.exist?(File.join('app', 'isomorfeus'))
           File.expand_path(File.join('app', 'isomorfeus', 'operations'))
         elsif Dir.exist?(File.join('isomorfeus'))
           File.expand_path(File.join('isomorfeus', 'operations'))
         end
  ActiveSupport::Dependencies.autoload_paths << path if path
  # we also need to require them all, so classes are registered accordingly
  Dir.glob("#{path}/**/*.rb").each do |file|
    require file
  end
end
