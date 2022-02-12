require 'base64'
require 'stringio'
require 'data_uri'
require 'securerandom'
require 'isomorfeus-policy'
require 'isomorfeus-transport'
require 'isomorfeus/data/config'
require 'isomorfeus/data/attribute_support'
require 'isomorfeus/data/field_support'
require 'isomorfeus/data/generic_class_api'
require 'isomorfeus/data/generic_instance_api'

if RUBY_ENGINE == 'opal'
  require 'isomorfeus/data/reducer'
  Isomorfeus::Data::Reducer.add_reducer_to_store
  Isomorfeus.zeitwerk.push_dir('isomorfeus_data')
  require_tree 'isomorfeus_data', autoload: true
  Isomorfeus.zeitwerk.push_dir('data')
else
  require 'fileutils'
  require 'uri'
  require 'oj'
  require 'active_support'
  require 'active_support/core_ext/hash'

  require 'isomorfeus-ferret'
  require 'isomorfeus/data/document_accelerator'

  require 'isomorfeus-hamster'
  require 'isomorfeus/data/object_expander'
  require 'isomorfeus/data/object_accelerator'

  require 'isomorfeus_data/lucid_query_result'
  require 'isomorfeus_data/lucid_object/mixin'
  require 'isomorfeus_data/lucid_object/base'
  require 'isomorfeus_data/lucid_document/mixin'
  require 'isomorfeus_data/lucid_document/base'
  require 'isomorfeus_data/lucid_query/mixin'
  require 'isomorfeus_data/lucid_query/base'
  require 'isomorfeus_data/lucid_file/mixin'
  require 'isomorfeus_data/lucid_file/base'

  require 'isomorfeus/data/handler/generic'

  require 'iso_opal'
  Opal.append_path(__dir__.untaint) unless IsoOpal.paths.include?(__dir__.untaint)
  uri_path = File.expand_path(File.join(__dir__.untaint, '..', 'opal'))
  Opal.append_path(uri_path) unless IsoOpal.paths.include?(uri_path)

  path = File.expand_path(File.join('app', 'data'))

  Isomorfeus.zeitwerk.push_dir(path)
end
