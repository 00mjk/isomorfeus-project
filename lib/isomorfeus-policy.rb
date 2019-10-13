require 'isomorfeus-react'
require 'isomorfeus/policy/config'
require 'lucid_policy/exception'
require 'isomorfeus/policy/helper'
require 'lucid_policy/mixin'
require 'lucid_policy/base'
require 'anonymous'
require 'isomorfeus/policy/anonymous_policy'

if RUBY_ENGINE == 'opal'
  Opal::Autoloader.add_load_path('policies')
else
  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  require 'zeitwerk'
  Isomorfeus.zeitwerk = Zeitwerk::Loader.new
  Isomorfeus.zeitwerk_mutex = Mutex.new if Isomorfeus.development?

  path = File.expand_path(File.join('isomorfeus', 'policies'))

  Isomorfeus.zeitwerk.push_dir(path)
end
