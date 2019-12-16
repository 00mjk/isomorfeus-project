require 'isomorfeus-react'
require 'isomorfeus/policy/config'
require 'lucid_policy/exception'
require 'isomorfeus/policy/helper'
require 'lucid_policy/mixin'
require 'lucid_policy/base'
require 'anonymous'
require 'isomorfeus/policy/anonymous_policy'

if RUBY_ENGINE == 'opal'
  Isomorfeus.zeitwerk.push_dir('policies')
else
  Opal.append_path(__dir__.untaint) unless Opal.paths.include?(__dir__.untaint)

  path = File.expand_path(File.join('isomorfeus', 'policies'))
  Isomorfeus.zeitwerk.push_dir(path)
end
