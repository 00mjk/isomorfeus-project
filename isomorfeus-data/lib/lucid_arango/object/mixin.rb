module LucidStorableObject
  module Mixin
    # TODO on revision conflict
    def self.included(base)
      base.include(Enumerable)
      base.extend(LucidPropDeclaration::Mixin)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)

      def to_gid
        [@class_name, @props_json]
      end

      base.instance_exec do
        def on_load_block
          @on_load_block
        end

        def load_query_block
          @load_query_block
        end
      end

      if RUBY_ENGINE == 'opal'
        def initialize(store_path: nil, validated_props: nil)
          @props = validated_props
          @props_json = @props.to_json if @props
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @store_path = store_path ? store_path : [:data_state, :arrays, @class_name, @props_json]
        end

        def loaded?
          Redux.fetch_by_path(*@store_path) ? true : false
        end

        def items
          raw_array = Redux.fetch_by_path(*@store_path)
          raw_array ? raw_array : []
        end

        def method_missing(method_name, *args, &block)
          raw_array = Redux.fetch_by_path(*@store_path)
          data_array = raw_array ? raw_array : []
          data_array.send(method_name, *args, &block)
        end

        def to_transport(inline: false)
          raw_array = Redux.fetch_by_path(*@store_path)
          if inline
            { '_inline' => { @props_json => (raw_array ? raw_array : []) }}
          else
            { 'arrays' => { @class_name => { @props_json => (raw_array ? raw_array : []) }}}
          end
        end

        base.instance_exec do
          def load(props_hash = {})
            validate_props(props_hash)
            # instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            self.promise_load(props_hash, instance) unless instance.loaded?
            instance
          end

          def on_load(&block)
          end

          def promise_load(props_hash = {}, instance = nil)
            unless instance
              validate_props(props_hash)
              # instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            end

            props_json = instance.instance_variable_get(:@props_json)

            Isomorfeus::Transport.promise_send_path('Isomorfeus::Data::Handler::Generic', self.name, props_json).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:error)
                  Isomorfeus.raise_error(message: agent.response[:error])
                end
                Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
                agent.result = instance
              end
            end
          end

          def load_query; end
        end
      else # RUBY_ENGINE
        unless base == LucidStorableObject::Base
          Isomorfeus.add_valid_data_class(base)
        end

        def initialize(store_path: nil, validated_props: nil)
          @props = validated_props
          @props_json = @props.to_json if @props
          @loaded = false
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end

        def loaded?
          @loaded
        end

        def [](name)
          @data_array[name]
        end

        def items
          @data_array
        end

        def method_missing(method_name, *args, &block)
          @data_array.send(method_name, *args, &block)
        end

        def to_transport(inline: false)
          if inline
            { '_inline' => { @props_json => @data_array }}
          else
            { 'arrays' => { @class_name => { @props_json => @data_array }}}
          end
        end

        base.instance_exec do
          def load(props_hash = {})
            validate_props(props_hash)
            # instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            instance.instance_exec do
              @data_array = self.class.load_query_block.call(props_hash)
              @loaded = true
            end
            instance
          end

          def on_load(&block)
            @on_load_block = block
          end

          def promise_load(props_hash = {}, instance = nil)
            instance = self.load(props_hash)
            result_promise = Promise.new
            result_promise.resolve(instance)
            result_promise
          end

          def load_query(&block)
            @load_query_block = block
          end
        end
      end  # RUBY_ENGINE
    end
  end
end
