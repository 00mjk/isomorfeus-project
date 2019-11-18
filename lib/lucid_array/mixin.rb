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

      if RUBY_ENGINE == 'opal'
        def initialize(key:, elements: nil)
          @key = key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_store_path = [:data_state, @class_name, @key]
          @_changed_store_path = [:data_state, :changed, @class_name, @key]
          el_con = self.class.element_conditions
          @_validate_elements = el_con ? true : false
          elements = [] unless elements
          if @_validate_elements
            elements.each do |e|
              Isomorfeus::Data::ElementValidator.new(@class_name, e, el_con).validate!
            end
          end
          Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: { @class_name => { @key => elements},
                                                               changed: { @class_name => { @key => false }}})
        end

        def _update_array(raw_array)
          Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: { @class_name => { @key => raw_array},
                                                               changed: { @class_name => { @key => true }}})
        end

        def each(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.each(&block)
        end

        def to_transport(inline: false)
          raw_array = Redux.fetch_by_path(*@_store_path)
          first_key = inline ? '_inline' : 'arrays'
          { first_key => { @class_name => { @key => raw_array }}}
        end

        # Array methods
        def method_missing(method_name, *args, &block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.send(method_name, *args, &block)
        end

        def <<(element)
          Isomorfeus::Data::ElementValidator.new(@class_name, element, self.class.element_conditions).validate! if @_validate_elements
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array << element
          _update_array(raw_array)
          result
        end

        def [](idx)
          Redux.fetch_by_path(*@_store_path)[idx]
        end

        def []=(idx, element)
          Isomorfeus::Data::ElementValidator.new(@class_name, element, self.class.element_conditions).validate! if @_validate_elements
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array[idx] = element
          _update_array(raw_array)
          element
        end

        def clear
          _update_array([])
          self
        end

        def collect!(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.collect!(&block)
          _update_array(raw_array)
          self
        end

        def compact!(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.compact!(&block)
          return nil if result.nil?
          _update_array(raw_array)
          self
        end

        def concat(*args)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.concat(*args)
          _update_array(raw_array)
          self
        end

        def delete(element, &block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.delete(element, &block)
          return nil if result.nil?
          _update_array(raw_array)
          result
        end

        def delete_at(idx)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.delete_at(idx)
          return nil if result.nil?
          _update_array(raw_array)
          result
        end

        def delete_if(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.delete_if(&block)
          _update_array(raw_array)
          self
        end

        def fill(*args, &block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.fill(*args, &block)
          _update_array(raw_array)
          self
        end

        def filter!(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.filter(&block)
          return nil if result.nil?
          _update_array(raw_array)
          self
        end

        def flatten!(level = nil)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.flatten!(level)
          return nil if result.nil?
          _update_array(raw_array)
          self
        end

        def insert(*args)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.insert(*args)
          _update_array(raw_array)
          self
        end

        def keep_if(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.keep_if(&block)
          _update_array(raw_array)
          self
        end

        def map!(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.map!(&block)
          _update_array(raw_array)
          self
        end

        def pop(n = nil)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.pop(n)
          _update_array(raw_array)
          result
        end

        def push(*elements)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.push(*elements)
          _update_array(raw_array)
          self
        end
        alias append push

        def reject!(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.reject!(&block)
          return nil if result.nil?
          _update_array(raw_array)
          self
        end

        def reverse!
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.reverse!
          _update_array(raw_array)
          self
        end

        def rotate!(count = 1)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.rotate!(count = 1)
          _update_array(raw_array)
          self
        end

        def select!(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.select!(&block)
          return nil if result.nil?
          _update_array(raw_array)
          self
        end

        def shift(n = nil)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.shift(n)
          _update_array(raw_array)
          result
        end

        def shuffle!(*args)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.shuffle!(*args)
          _update_array(raw_array)
          self
        end

        def slice!(*args)
          raw_array = Redux.fetch_by_path(*@_store_path)
          result = raw_array.slice!(*args)
          _update_array(raw_array)
          result
        end

        def sort!(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.sort!(&block)
          _update_array(raw_array)
          self
        end

        def sort_by!(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.sort_by!(&block)
          _update_array(raw_array)
          self
        end

        def uniq!(&block)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.uniq!(&block)
          _update_array(raw_array)
          self
        end

        def unshift(*args)
          raw_array = Redux.fetch_by_path(*@_store_path)
          raw_array.unshift(*args)
          _update_array(raw_array)
          self
        end
        alias prepend unshift
      else # RUBY_ENGINE
        unless base == LucidArray::Base
          Isomorfeus.add_valid_array_class(base)
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: Anonymous.new
        end

        def initialize(key:, elements: nil)
          @key = key.to_s
          @_changed = false
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          el_con = self.class.element_conditions
          @_validate_elements = el_con ? true : false
          elements = [] unless elements
          if @_validate_elements
            elements.each do |e|
              Isomorfeus::Data::ElementValidator.new(@class_name, e, el_con).validate!
            end
          end
          @_raw_array = elements
        end

        def each(&block)
          @_raw_array.each(&block)
        end

        def to_transport(inline: false)
          first_key = inline ? '_inline' : 'arrays'
          { first_key => { @class_name => { @key => @_raw_array }}}
        end

        # Array methods
        def method_missing(method_name, *args, &block)
          @_raw_array.send(method_name, *args, &block)
        end

        def <<(element)
          Isomorfeus::Data::ElementValidator.new(@class_name, element, self.class.element_conditions).validate! if @_validate_elements
          @_changed = true
          @_raw_array << element
        end

        def []=(idx, element)
          Isomorfeus::Data::ElementValidator.new(@class_name, element, self.class.element_conditions).validate! if @_validate_elements
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
          return nil if result.nil?
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
