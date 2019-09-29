module LucidHash
  module Mixin
    def self.included(base)
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_hash_class(base) unless base == LucidHash::Base
      end

      base.extend(LucidPropDeclaration::Mixin)

      def to_gid
        [@class_name, @props_json]
      end

      def to_transport(inline: false)
        if inline
          { '_inline' => { @props_json => to_h }}
        else
          { 'hashes' => { @class_name => { @props_json => to_h }}}
        end
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
          @store_path = store_path ? store_path : [:data_state, :hashes, @class_name]
        end

        def loaded?
          Redux.fetch_by_path(*(@store_path + [@props_json])) ? true : false
        end

        def [](name)
          path = @store_path + [@props_json, name]
          result = Redux.fetch_by_path(*path)
          result ? result : nil
        end

        def key?(name)
          path = @store_path + [@props_json, name]
          Redux.fetch_by_path(*path) ? true : false
        end

        def method_missing(method_name, *args, &block)
          path = @store_path + [@props_json]
          raw_hash = Redux.fetch_by_path(*path)
          if raw_hash
            Hash.new(raw_hash).send(method_name, *args, &block)
          else
            Hash.new.send(method_name, *args, &block)
          end
        end

        def to_h
          raw_hash = Redux.fetch_by_path(*(@store_path + [@props_json]))
          raw_hash ? Hash.new(raw_hash) : {}
        end

        base.instance_exec do
          def load(props_hash = {})
            validate_props(props_hash)
            instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            self.promise_load(props_hash, instance) unless instance.loaded?
            instance
          end

          def on_load(&block)
          end

          def promise_load(props_hash = {}, instance = nil)
            unless instance
              validate_props(props_hash)
              instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            end

            props_json = instance.instance_variable_get(:@props_json)

            Isomorfeus::Transport.promise_send_path('Isomorfeus::Data::Handler::HashLoadHandler', self.name, props_json).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:error)
                  `console.error(#{agent.response[:error].to_n})`
                  raise agent.response[:error]
                end
                Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
                agent.result = instance
              end
            end
          end

          def load_query; end
        end
      else # RUBY_ENGINE
        unless base == LucidHash::Base
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: nil
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
          @data_hash[name]
        end

        def method_missing(method_name, *args, &block)
          @data_hash.send(method_name, *args, &block)
        end

        def to_h
          @data_hash.to_h.transform_keys { |k| k.to_s }
        end

        base.instance_exec do
          def load(props_hash = {})
            validate_props(props_hash)
            instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            instance.instance_exec do
              @data_hash = self.class.load_query_block.call(props_hash)
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
