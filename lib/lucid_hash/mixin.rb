module LucidHash
  module Mixin
    def self.included(base)
      base.include(Enumerable)
      base.extend(LucidPropDeclaration::Mixin)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)

      attr_accessor :default
      attr_accessor :default_proc

      base.instance_exec do
        def _handler_type
          'hash'
        end

        def attribute_conditions
          @attribute_conditions ||= {}
        end

        def valid_attribute?(attr_name, attr_value)
          return true unless @attribute_options
          Isomorfeus::Props::Validator.new(self.name, attr_name, attr_value, attribute_conditions[attr_name]).validate!
        rescue
          false
        end
      end

      def to_transport(inline: false)
        first_key = inline ? '_inline' : 'hashes'
        { first_key => { @class_name => { @key => to_h }}}
      end

      def _validate_attribute(attr_name, attr_val)
        Isomorfeus::Props::Validator.new(@class_name, attr_name, attr_val, self.class.attribute_conditions[attr_name]).validate!
      end

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def attribute(name, options = {})
            attribute_conditions[name] = options

            define_method(name) do
              path = @store_path + [name]
              result = Redux.fetch_by_path(*path)
              result ? result : nil
            end

            define_method("#{name}=") do |arg|
              _validate_attribute(name, arg) if @_validate_attributes
              @attributes.set(name, arg)
            end
          end
        end

        def initialize(key:, attributes: nil, default: nil, &block)
          @default = default
          @default_proc = block
          @key = key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_store_path = [:data_state, @class_name, @key]
          @_changed_store_path = [:data_state, :changed, @class_name, @key]
          @_validate_attributes = self.class.attribute_conditions.any?
          attributes = {} unless attributes
          if @_validate_attributes
            attributes.each { |a,v| _validate_attribute(a, v) }
          end
          Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: { @class_name => { @key => attributes },
                                                               changed: { @class_name => { @key => false }}})
        end

        def _update_attribute(attr_name, attr_val)
          Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: { @class_name => { @key => { attr_name => attr_val }},
                                                               changed: { @class_name => { @key => true }}})
        end

        def _update_attributes(hash)
          Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: { @class_name => { @key => hash},
                                                               changed: { @class_name => { @key => true }}})
        end

        def each(&block)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          Hash.new(raw_attributes).each(&block)
        end

        def [](name)
          path = @store_path + [name]
          result = Redux.fetch_by_path(*path)
          return result if result
          return @default unless @default_proc
          @default_proc.call(self, name)
          Redux.fetch_by_path(*path)
        end

        def []=(name, val)
          _validate_attribute(name, val) if @_validate_attributes
          _update_attribute(name, val)
          val
        end

        def compact!
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          result = Hash.new(raw_attributes).compact!
          return nil if result.nil?
          _update_attributes(result)
          self
        end

        def delete(name)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          hash = Hash.new(raw_attributes)
          result = hash.delete(name)
          _update_attributes(hash)
          result
        end

        def delete_if(&block)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          raw_hash = Hash.new(raw_attributes)
          result = raw_hash.delete_if(&block)
          _update_attributes(raw_hash)
          result
        end

        def method_missing(name, *args, &block)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          Hash.new(raw_attributes).send(name, *args, &block)
        end

        def key?(name)
          path = @store_path + [name]
          Redux.fetch_by_path(*path) ? true : false
        end
        alias has_key? key?

        def keep_if(&block)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          raw_hash = Hash.new(raw_attributes)
          raw_hash.keep_if(&block)
          _update_array(raw_hash)
          self
        end

        def merge!(*args)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          raw_hash = Hash.new(raw_attributes)
          raw_hash.merge!(*args)
          _update_attributes(raw_hash)
          self
        end

        def reject!(&block)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          raw_hash = Hash.new(raw_attributes)
          result = raw_hash.reject!(&block)
          return nil if result.nil?
          _update_attributes(raw_hash)
          self
        end

        def select!(&block)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          raw_hash = Hash.new(raw_attributes)
          result = raw_hash.select!(&block)
          return nil if result.nil?
          _update_attributes(raw_hash)
          self
        end
        alias filter! select!

        def shift
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          raw_hash = Hash.new(raw_attributes)
          result = raw_hash.shift
          _update_array(raw_hash)
          result
        end

        def store(name, val)
          _validate_attribute(name, val) if @_validate_attributes
          _update_attribute(name, val)
          val
        end

        def to_h
          raw_hash = Redux.fetch_by_path(*@store_path)
          raw_hash ? Hash.new(raw_hash) : {}
        end

        def transform_keys!(&block)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          raw_hash = Hash.new(raw_attributes)
          raw_hash.transform_keys!(&block)
          _update_array(raw_hash)
          self
        end

        def transform_values!(&block)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          raw_hash = Hash.new(raw_attributes)
          raw_hash.transform_values!(&block)
          _update_array(raw_hash)
          self
        end
      else # RUBY_ENGINE
        unless base == LucidHash::Base
          Isomorfeus.add_valid_hash_class(base)
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: Anonymous.new
        end

        def initialize(key:, attributes: nil)
          @key = key.to_s
          @_changed = false
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_validate_attributes = self.class.attribute_conditions.any?
          attributes = {} unless attributes
          if @_validate_attributes
            attributes.each { |a,v| _validate_attribute(a, v) }
          end
          @_raw_attributes = attributes
        end

        def each(&block)
          @_raw_attributes.each(&block)
        end

        def [](name)
          @_raw_attributes[name]
        end

        def []=(name, val)
          _validate_attribute(name, val) if @_validate_attributes
          @_changed = true
          @_raw_attributes[name] = val
        end

        def compact!(&block)
          result = @_raw_attributes.compact!(&block)
          return nil if result.nil?
          @_changed = true
          self
        end

        def delete(element, &block)
          result = @_raw_attributes.delete(element, &block)
          @_changed = true
          result
        end

        def delete_if(&block)
          @_raw_attributes.delete_if(&block)
          @_changed = true
          self
        end

        def keep_if(&block)
          @_raw_attributes.keep_if(&block)
          @_changed = true
          self
        end

        def method_missing(method_name, *args, &block)
          @_raw_attributes.send(method_name, *args, &block)
        end

        def merge!(*args)
          @_raw_attributes.merge!(*args)
          @_changed = true
          self
        end

        def reject!(&block)
          result = @_raw_attributes.reject!(&block)
          return nil if result.nil?
          @_changed = true
          self
        end

        def select!(&block)
          result = @_raw_attributes.select!(&block)
          return nil if result.nil?
          @_changed = true
          self
        end
        alias filter! select!

        def shift
          result = @_raw_attributes.shift
          @_changed = true
          result
        end

        def store(name, val)
          _validate_attribute(name, val) if @_validate_attributes
          @_changed = true
          @_raw_attributes[name] = val
        end

        def to_h
          @_raw_attributes.to_h.transform_keys { |k| k.to_s }
        end

        def transform_keys!(&block)
          @_raw_attributes.transform_keys!(&block)
          @_changed = true
          self
        end

        def transform_values!(&block)
          @_raw_attributes.transform_values!(&block)
          @_changed = true
          self
        end
      end  # RUBY_ENGINE
    end
  end
end
