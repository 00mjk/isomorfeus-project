require 'opal'
require 'isomorfeus-redux'
require 'isomorfeus-react'
require 'isomorfeus/policy/config'
require 'lucid_policy/exception'
require 'isomorfeus/policy/helper'
require 'lucid_policy/mixin'
require 'lucid_policy/base'

if RUBY_ENGINE == 'opal'
  Opal::Autoloader.add_load_path('policies')
else
  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  require 'active_support/dependencies'

  path = File.expand_path(File.join('isomorfeus', 'policies'))

  ActiveSupport::Dependencies.autoload_paths << path
  # we also need to require them all, so classes are registered accordingly
  Dir.glob("#{path}/**/*.rb").each do |file|
    require file
  end
end