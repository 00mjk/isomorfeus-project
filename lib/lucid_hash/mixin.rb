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
          return true unless @attribute_conditions
          Isomorfeus::Props::Validator.new(self.name, attr_name, attr_value, attribute_conditions[attr_name]).validate!
        rescue
          false
        end
      end

      def to_transport
        { @class_name => { @key => to_h }}
      end

      def _validate_attribute(attr_name, attr_val)
        Isomorfeus::Props::Validator.new(@class_name, attr_name, attr_val, self.class.attribute_conditions[attr_name]).validate!
      end

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def attribute(name, options = {})
            attribute_conditions[name] = options

            define_method(name) do
              result = _get_attribute(name)
              if result
                result
              elsif !@_default_proc
                @_default
              else
                @_default_proc.call(self, name)
              end
            end

            define_method("#{name}=") do |val|
              _validate_attribute(name, val) if @_validate_attributes
              @_changed_attributes[name] = val
              val
            end
          end
        end

        def initialize(key:, revision: nil,  attributes: nil, default: nil, &block)
          @_default = default
          @_default_proc = block
          @key = key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_store_path = [:data_state, @class_name, @key]
          @_changed_attributes = {}
          @_revision_store_path = [:data_state, :revision, @class_name, @key]
          @_revision = revision ? revision : Redux.fetch_by_path(*@_revision_store_path)
          @_validate_attributes = self.class.attribute_conditions.any?
          attributes = {} unless attributes
          if @_validate_attributes
            attributes.each { |a,v| _validate_attribute(a, v) }
          end
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          if `raw_attributes === null`
            @_changed_attributes = !attributes ? {} : attributes
          elsif raw_attributes && !attributes.nil? && raw_attributes != attributes
            @_changed_attributes = attributes
          end
        end

        def _get_attribute(name)
          return @_changed_attributes[name] if @_changed_attributes && @_changed_attributes.key?(name)
          path = @_store_path + [name]
          result = Redux.fetch_by_path(*path)
          return nil if `result === null`
          result
        end

        def _get_attributes
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          hash = Hash.new(raw_attributes)
          hash.merge!(@_changed_attributes) if @_changed_attributes
          hash
        end

        def changed?
          @_changed_attributes.any?
        end

        def revision
          @_revision
        end

        def each(&block)
          _get_attributes.each(&block)
        end

        def [](name)
          result = _get_attribute(name)
          return result if result
          return @_default unless @_default_proc
          @_default_proc.call(self, name)
        end

        def []=(name, val)
          _validate_attribute(name, val) if @_validate_attributes
          @_changed_attributes[name] = val
          val
        end

        def compact!
          result = _get_attributes.compact!
          return nil if result.nil?
          @_changed_attributes = result
          self
        end

        def delete(name)
          hash = _get_attributes
          result = hash.delete(name)
          @_changed_attributes = hash
          result
        end

        def delete_if(&block)
          hash = _get_attributes
          result = hash.delete_if(&block)
          @_changed_attributes = hash
          result
        end

        def method_missing(method_name, *args, &block)
          if method_name.end_with?('=')
            val = args[0]
            _validate_attribute(method_name, val) if @_validate_attributes
            @_changed_attributes[method_name] = val
          elsif args.size == 0 && hash.key?(method_name)
            result = _get_attribute(method_name)
            return result if result
            return @_default unless @_default_proc
            @_default_proc.call(self, method_name)
          else
            hash = _get_attributes
            hash.send(name, *args, &block)
          end
        end

        def key?(name)
          _get_attribute(method_name) ? true : false
        end
        alias has_key? key?

        def keep_if(&block)
          raw_hash = _get_attributes
          raw_hash.keep_if(&block)
          _update_array(raw_hash)
          self
        end

        def merge!(*args)
          @_changed_attributes = _get_attributes.merge!(*args)
          self
        end

        def reject!(&block)
          hash = _get_attributes
          result = hash.reject!(&block)
          return nil if result.nil?
          @_changed_attributes = hash
          self
        end

        def select!(&block)
          hash = _get_attributes
          result = ash.select!(&block)
          return nil if result.nil?
          @_changed_attributes = hash
          self
        end
        alias filter! select!

        def shift
          hash = _get_attributes
          result = hash.shift
          @_changed_attributes = hash
          result
        end

        def store(name, val)
          _validate_attribute(name, val) if @_validate_attributes
          @_changed_attributes[name] = val
          val
        end

        def to_h
          hash = _get_attributes
          hash.merge(_revision: revision)
        end

        def transform_keys!(&block)
          @_changed_attributes = _get_attributes.transform_keys!(&block)
          self
        end

        def transform_values!(&block)
          @_changed_attributes = _get_attributes.transform_values!(&block)
          self
        end

        def update(*args)
          @_changed_attributes = _get_attributes.update(*args)
          self
        end
      else # RUBY_ENGINE
        unless base == LucidHash::Base
          Isomorfeus.add_valid_hash_class(base)
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: Anonymous.new
        end

        base.instance_exec do
          def attribute(name, options = {})
            attribute_conditions[name] = options

            define_method(name) do
              @_raw_attributes[name]
            end

            define_method("#{name}=") do |val|
              _validate_attribute(name, val) if @_validate_attributes
              @_changed = true
              @_raw_attributes[name] = val
            end
          end
        end

        def initialize(key:, revision: nil, attributes: nil)
          @key = key.to_s
          @_revision = revision
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

        def changed?
          @_changed
        end

        def revision
          @_revision
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
          if method_name.end_with?('=')
            val = args[0]
            _validate_attribute(name, val) if @_validate_attributes
            @_changed = true
            @_raw_attributes[name] = val
          elsif args.size == 0 && @_raw_attributes.key?(method_name)
            @_raw_attributes[method_name]
          else
            @_raw_attributes.send(method_name, *args, &block)
          end
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
          @_raw_attributes.to_h.merge(_revision: @_revision).transform_keys { |k| k.to_s }
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

        def update(*args)
          @_raw_attributes.update(*args)
          @_changed = true
          self
        end
      end  # RUBY_ENGINE
    end
  end
end
