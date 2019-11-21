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

        def elements(validate_hash = {})
          @element_conditions = validate_hash
        end
        alias element elements

        def element_conditions
          @element_conditions
        end

        def valid_element?(element)
          return true unless @element_conditions
          Isomorfeus::Data::ElementValidator.new(self.name, element, @element_conditions).validate!
        rescue
          false
        end
      end

      def _validate_element(el)
        Isomorfeus::Data::ElementValidator.new(@class_name, el, @el_con).validate!
      end

      if RUBY_ENGINE == 'opal'
        def initialize(key:, revision: nil, elements: nil)
          @key = key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_store_path = [:data_state, @class_name, @key]
          @_changed_array = nil
          @_revision_store_path = [:data_state, :revision, @class_name, @key]
          @_revision = revision ? revision : Redux.fetch_by_path(*@_revision_store_path)
          @el_con = self.class.element_conditions
          @_validate_elements = @el_con ? true : false
          elements = [] unless elements
          if @_validate_elements
            elements.each { |e| _validate_element(e) }
          end
          raw_array = Redux.fetch_by_path(*@_store_path)
          if `raw_array === null`
            @_changed_array = !elements ? [] : elements
          elsif raw_array && !elements.nil? && raw_array != elements
            @_changed_array = elements
          end
        end

        def _get_array
          return @_changed_array if @_changed_array
          Redux.fetch_by_path(*@_store_path)
        end

        def changed?
          !!@_changed_array
        end

        def revision
          @_revision
        end

        def each(&block)
          _get_array.each(&block)
        end

        def to_transport
          raw_array = _get_array
          { @class_name => { @key => raw_array }}
        end

        # Array methods
        def method_missing(method_name, *args, &block)
          raw_array = _get_array
          raw_array.send(method_name, *args, &block)
        end

        def <<(element)
          _validate_element(element) if @_validate_elements
          raw_array = _get_array
          result = raw_array << element
          @_changed_array = raw_array
          result
        end

        def [](idx)
          _get_array[idx]
        end

        def []=(idx, element)
          _validate_element(element) if @_validate_elements
          raw_array = _get_array
          raw_array[idx] = element
          @_changed_array = raw_array
          element
        end

        def clear
          @_changed_array = []
          self
        end

        def collect!(&block)
          raw_array = _get_array
          raw_array.collect!(&block)
          @_changed_array = raw_array
          self
        end

        def compact!(&block)
          raw_array = _get_array
          result = raw_array.compact!(&block)
          return nil if result.nil?
          @_changed_array = raw_array
          self
        end

        def concat(*args)
          raw_array = _get_array
          raw_array.concat(*args)
          @_changed_array = raw_array
          self
        end

        def delete(element, &block)
          raw_array = _get_array
          result = raw_array.delete(element, &block)
          return nil if result.nil?
          @_changed_array = raw_array
          result
        end

        def delete_at(idx)
          raw_array = _get_array
          result = raw_array.delete_at(idx)
          return nil if result.nil?
          @_changed_array = raw_array
          result
        end

        def delete_if(&block)
          raw_array = _get_array
          raw_array.delete_if(&block)
          @_changed_array = raw_array
          self
        end

        def fill(*args, &block)
          raw_array = _get_array
          raw_array.fill(*args, &block)
          @_changed_array = raw_array
          self
        end

        def filter!(&block)
          raw_array = _get_array
          result = raw_array.filter!(&block)
          return nil if result.nil?
          @_changed_array = raw_array
          self
        end

        def flatten!(level = nil)
          raw_array = _get_array
          result = raw_array.flatten!(level)
          return nil if result.nil?
          @_changed_array = raw_array
          self
        end

        def insert(*args)
          raw_array = _get_array
          raw_array.insert(*args)
          @_changed_array = raw_array
          self
        end

        def keep_if(&block)
          raw_array = _get_array
          raw_array.keep_if(&block)
          @_changed_array = raw_array
          self
        end

        def map!(&block)
          raw_array = _get_array
          raw_array.map!(&block)
          @_changed_array = raw_array
          self
        end

        def pop(n = nil)
          raw_array = _get_array
          result = raw_array.pop(n)
          @_changed_array = raw_array
          result
        end

        def push(*elements)
          if @_validate_elements
            elements.each { |element| _validate_element(element) }
          end
          raw_array = _get_array
          raw_array.push(*elements)
          @_changed_array = raw_array
          self
        end
        alias append push

        def reject!(&block)
          raw_array = _get_array
          result = raw_array.reject!(&block)
          return nil if result.nil?
          @_changed_array = raw_array
          self
        end

        def reverse!
          raw_array = _get_array
          raw_array.reverse!
          @_changed_array = raw_array
          self
        end

        def rotate!(count = 1)
          raw_array = _get_array
          raw_array.rotate!(count = 1)
          @_changed_array = raw_array
          self
        end

        def select!(&block)
          raw_array = _get_array
          result = raw_array.select!(&block)
          return nil if result.nil?
          @_changed_array = raw_array
          self
        end

        def shift(n = nil)
          raw_array = _get_array
          result = raw_array.shift(n)
          @_changed_array = raw_array
          result
        end

        def shuffle!(*args)
          raw_array = _get_array
          raw_array.shuffle!(*args)
          @_changed_array = raw_array
          self
        end

        def slice!(*args)
          raw_array = _get_array
          result = raw_array.slice!(*args)
          @_changed_array = raw_array
          result
        end

        def sort!(&block)
          raw_array = _get_array
          raw_array.sort!(&block)
          @_changed_array = raw_array
          self
        end

        def sort_by!(&block)
          raw_array = _get_array
          raw_array.sort_by!(&block)
          @_changed_array = raw_array
          self
        end

        def uniq!(&block)
          raw_array = _get_array
          raw_array.uniq!(&block)
          @_changed_array = raw_array
          self
        end

        def unshift(*args)
          raw_array = _get_array
          raw_array.unshift(*args)
          @_changed_array = raw_array
          self
        end
        alias prepend unshift
      else # RUBY_ENGINE
        unless base == LucidArray::Base
          Isomorfeus.add_valid_array_class(base)
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: Anonymous.new
        end

        def initialize(key:, revision: nil, elements: nil)
          @key = key.to_s
          @_revision = revision
          @_changed = false
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @el_con = self.class.element_conditions
          @_validate_elements = @el_con ? true : false
          elements = [] unless elements
          if @_validate_elements
            elements.each { |e| _validate_element(e) }
          end
          @_raw_array = elements
        end

        def changed?
          @_changed
        end

        def revision
          @_revision
        end

        def each(&block)
          @_raw_array.each(&block)
        end

        def to_transport(inline: false)
          { @class_name => { @key => @_raw_array }}
        end

        # Array methods
        def method_missing(method_name, *args, &block)
          @_raw_array.send(method_name, *args, &block)
        end

        def <<(element)
          _validate_element(element) if @_validate_elements
          @_changed = true
          @_raw_array << element
        end

        def []=(idx, element)
          _validate_element(element) if @_validate_elements
          @_changed = true
          @_raw_array[idx] = element
        end

        def clear
          @_raw_array = []
          self
        end

        def collect!(&block)
          @_changed = true
          @_raw_array.collect!(&block)
          self
        end

        def compact!(&block)
          result = @_raw_array.compact!(&block)
          return nil if result.nil?
          @_changed = true
          self
        end

        def concat(*args)
          @_changed = true
          @_raw_array.concat(*args)
          self
        end

        def delete(element, &block)
          result = @_raw_array.delete(element, &block)
          @_changed = true
          result
        end

        def delete_at(idx)
          result = @_raw_array.delete_at(idx)
          return nil if result.nil?
          @_changed = true
          result
        end

        def delete_if(&block)
          @_raw_array.delete_if(&block)
          @_changed = true
          self
        end

        def fill(*args, &block)
          @_raw_array.fill(*args, &block)
          @_changed = true
          self
        end

        def filter!(&block)
          result = @_raw_array.filter!(&block)
          return nil if result.nil?
          @_changed = true
          self
        end

        def flatten!(level = nil)
          result = @_raw_array.flatten!(level)
          return nil if result.nil?
          @_changed = true
          self
        end

        def insert(*args)
          @_raw_array.insert(*args)
          @_changed = true
          self
        end

        def keep_if(&block)
          @_raw_array.keep_if(&block)
          @_changed = true
          self
        end

        def map!(&block)
          @_raw_array.map!(&block)
          @_changed = true
          self
        end

        def pop(n = nil)
          result = @_raw_array.pop(n)
          @_changed = true
          result
        end

        def push(*elements)
          if @_validate_elements
            elements.each { |element| _validate_element(element) }
          end
          @_raw_array.push(*elements)
          @_changed = true
          self
        end
        alias append push

        def reject!(&block)
          result = @_raw_array.reject!(&block)
          return nil if result.nil?
          @_changed = true
          self
        end

        def reverse!
          @_raw_array.reverse!
          @_changed = true
          self
        end

        def rotate!(count = 1)
          @_raw_array.rotate!(count = 1)
          @_changed = true
          self
        end

        def select!(&block)
          result = @_raw_array.select!(&block)
          return nil if result.nil?
          @_changed = true
          self
        end

        def shift(n = nil)
          result = @_raw_array.shift(n)
          @_changed = true
          result
        end

        def shuffle!(*args)
          @_raw_array.shuffle!(*args)
          @_changed = true
          self
        end

        def slice!(*argsk)
          result = @_raw_array.slice!(*args)
          @_changed = true
          result
        end

        def sort!(&block)
          @_raw_array.sort!(&block)
          @_changed = true
          self
        end

        def sort_by!(&block)
          @_raw_array.sort_by!(&block)
          @_changed = true
          self
        end

        def uniq!(&block)
          @_raw_array.uniq!(&block)
          @_changed = true
          self
        end

        def unshift(*args)
          @_raw_array.unshift(*args)
          @_changed = true
          self
        end
        alias prepend unshift
      end  # RUBY_ENGINE
    end
  end
end
