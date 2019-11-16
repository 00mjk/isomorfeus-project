module LucidArray
  module Mixin
    def self.included(base)
      base.include(Enumerable)
      base.extend(LucidPropDeclaration::Mixin)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)

      base.instance_exec do
        def _handler_type
          'array'
        end
      end

      if RUBY_ENGINE == 'opal'
        def initialize(key, array_of_items = nil)
          @key = key
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_store_path = [:data_state, :arrays, @class_name, @key]
          Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: array_of_items) if array_of_items
        end

        def each(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          (raw_array ? raw_array : []).each(&block)
        end

        def to_transport(inline: false)
          raw_array = Redux.fetch_by_path(*@_store_path)
          first_key = inline ? '_inline' : 'arrays'
          { first_key => { @class_name => { @key => (raw_array ? raw_array : []) }}}
        end
      else # RUBY_ENGINE
        unless base == LucidArray::Base
          Isomorfeus.add_valid_array_class(base)
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: Anonymous.new
        end

        def initialize(key, array_of_items = nil)
          @key = key
          @_data_array = array_of_items
          @_loaded = false
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end

        def each(&block)
          @_data_array.each(&block)
        end

        def to_transport(inline: false)
          first_key = inline ? '_inline' : 'arrays'
          { first_key => { @class_name => { @key => @_data_array }}}
        end
      end  # RUBY_ENGINE
    end
  end
end
