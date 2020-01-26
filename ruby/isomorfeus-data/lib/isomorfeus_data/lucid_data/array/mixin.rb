module LucidData
  module Array
    module Mixin
      def self.included(base)
        base.include(Enumerable)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)

        base.instance_exec do
          def elements(validate_hash = {})
            @element_conditions = validate_hash
          end
          alias element elements

          def element_conditions
            @element_conditions ||= {}
          end

          def valid_element?(element)
            return true unless element_conditions.any?
            _validate_element(element)
          rescue
            false
          end

          def _validate_element(element)
            Isomorfeus::Data::ElementValidator.new(self.to_s, element, element_conditions).validate!
          end

          def _validate_elements(many_els)
            many_els.each { |e| _validate_element(e) } if element_conditions.any?
          end
        end

        def composition
          @_composition
        end

        def composition=(c)
          @_composition = c
        end

        def changed!
          @_composition.changed! if @_composition
          @_changed = true
        end

        def _validate_element(element)
          self.class._validate_element(element)
        end

        def _validate_elements(many_elements)
          self.class._validate_elements(many_elements)
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, elements: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_store_path = [:data_state, @class_name, @key, :elements]
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, @class_name, @key, :revision)
            @_changed_array = nil
            @_composition = composition
            @_changed = false
            @_validate_elements = self.class.element_conditions.any?
            _validate_elements(elements)
            raw_array = Redux.fetch_by_path(*@_store_path)
            if `raw_array === null`
              @_changed_array = elements ? elements : []
            elsif raw_array && !elements.nil?
              @_changed_array = elements
            end
          end

          def _load_from_store!
            @_changed = false
            @_changed_array = nil
          end

          def _get_array
            return @_changed_array if @_changed_array
            Redux.fetch_by_path(*@_store_path)
          end

          def changed?
            @_changed || !!@_changed_array
          end

          def each(&block)
            _get_array.each(&block)
          end

          def to_transport
            hash = { 'elements' => _get_array }
            hash.merge!('revision' => revision) if revision
            { @class_name => { @key =>  hash }}
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
            changed!
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
            changed!
            element
          end

          def clear
            @_changed_array = []
            changed!
            self
          end

          def collect!(&block)
            raw_array = _get_array
            raw_array.collect!(&block)
            @_changed_array = raw_array
            changed!
            self
          end

          def compact!
            raw_array = _get_array
            result = raw_array.compact!
            return nil if result.nil?
            @_changed_array = raw_array
            changed!
            self
          end

          def concat(*args)
            raw_array = _get_array
            raw_array.concat(*args)
            @_changed_array = raw_array
            changed!
            self
          end

          def delete(element, &block)
            raw_array = _get_array
            result = raw_array.delete(element, &block)
            return nil if result.nil?
            @_changed_array = raw_array
            changed!
            result
          end

          def delete_at(idx)
            raw_array = _get_array
            result = raw_array.delete_at(idx)
            return nil if result.nil?
            @_changed_array = raw_array
            changed!
            result
          end

          def delete_if(&block)
            raw_array = _get_array
            raw_array.delete_if(&block)
            @_changed_array = raw_array
            changed!
            self
          end

          def fill(*args, &block)
            raw_array = _get_array
            raw_array.fill(*args, &block)
            @_changed_array = raw_array
            changed!
            self
          end

          def filter!(&block)
            raw_array = _get_array
            result = raw_array.filter!(&block)
            return nil if result.nil?
            @_changed_array = raw_array
            changed!
            self
          end

          def flatten!(level = nil)
            raw_array = _get_array
            result = raw_array.flatten!(level)
            return nil if result.nil?
            @_changed_array = raw_array
            changed!
            self
          end

          def insert(*args)
            raw_array = _get_array
            raw_array.insert(*args)
            @_changed_array = raw_array
            changed!
            self
          end

          def keep_if(&block)
            raw_array = _get_array
            raw_array.keep_if(&block)
            @_changed_array = raw_array
            changed!
            self
          end

          def map!(&block)
            raw_array = _get_array
            raw_array.map!(&block)
            @_changed_array = raw_array
            changed!
            self
          end

          def pop(n = nil)
            raw_array = _get_array
            result = raw_array.pop(n)
            @_changed_array = raw_array
            changed!
            result
          end

          def push(*elements)
            if @_validate_elements
              elements.each { |element| _validate_element(element) }
            end
            raw_array = _get_array
            raw_array.push(*elements)
            @_changed_array = raw_array
            changed!
            self
          end
          alias append push

          def reject!(&block)
            raw_array = _get_array
            result = raw_array.reject!(&block)
            return nil if result.nil?
            @_changed_array = raw_array
            changed!
            self
          end

          def reverse!
            raw_array = _get_array
            raw_array.reverse!
            @_changed_array = raw_array
            changed!
            self
          end

          def rotate!(count = 1)
            raw_array = _get_array
            raw_array.rotate!(count)
            @_changed_array = raw_array
            changed!
            self
          end

          def select!(&block)
            raw_array = _get_array
            result = raw_array.select!(&block)
            return nil if result.nil?
            @_changed_array = raw_array
            changed!
            self
          end

          def shift(n = nil)
            raw_array = _get_array
            result = raw_array.shift(n)
            @_changed_array = raw_array
            changed!
            result
          end

          def shuffle!(*args)
            raw_array = _get_array
            raw_array.shuffle!(*args)
            @_changed_array = raw_array
            changed!
            self
          end

          def slice!(*args)
            raw_array = _get_array
            result = raw_array.slice!(*args)
            @_changed_array = raw_array
            changed!
            result
          end

          def sort!(&block)
            raw_array = _get_array
            raw_array.sort!(&block)
            @_changed_array = raw_array
            changed!
            self
          end

          def sort_by!(&block)
            raw_array = _get_array
            raw_array.sort_by!(&block)
            @_changed_array = raw_array
            changed!
            self
          end

          def uniq!(&block)
            raw_array = _get_array
            raw_array.uniq!(&block)
            @_changed_array = raw_array
            changed!
            self
          end

          def unshift(*args)
            raw_array = _get_array
            raw_array.unshift(*args)
            @_changed_array = raw_array
            changed!
            self
          end
          alias prepend unshift
        else # RUBY_ENGINE
          Isomorfeus.add_valid_data_class(base) unless base == LucidData::Array::Base

          base.instance_exec do
            def load(key:, pub_sub_client: nil, current_user: nil)
              data = instance_exec(key: key, pub_sub_client: pub_sub_client, current_user: current_user, &@_load_block)
              return nil unless data
              return data if data.class == self
              Isomorfeus.raise_error "#{self.to_s}: execute_load must return either a Hash or a instance of #{self.to_s}. Returned was: #{data.class}." if data.class != ::Hash
              revision = data.delete(:revision)
              elements = data.delete(:elements)
              self.new(key: key, revision: revision, elements: elements)
            end

            def save(key:, revision: nil, elements: nil, pub_sub_client: nil, current_user: nil)
              _validate_elements(elements)
              data = instance_exec(key: key, revision: revision, elements: elements,
                                   pub_sub_client: pub_sub_client, current_user: current_user, &@_save_block)
              return nil unless data
              return data if data.class == self
              Isomorfeus.raise_error "#{self.to_s}: execute_save must return either a Hash or a instance of #{self.to_s}. Returned was: #{data.class}." if data.class != ::Hash
              revision = data.delete(:revision)
              elements = data.delete(:elements)
              self.new(key: key, revision: revision, elements: elements)
            end
          end

          def initialize(key:, revision: nil, elements: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_changed = false
            @_composition = composition
            elements = [] unless elements
            @_validate_elements = self.class.element_conditions.any?
            _validate_elements(elements)
            @_raw_array = elements
          end

          def changed?
            @_changed
          end

          def each(&block)
            @_raw_array.each(&block)
          end

          def to_transport
            hash = { 'elements' => @_raw_array }
            hash.merge!('revision' => revision) if revision
            { @class_name => { @key => hash }}
          end

          # Array methods
          def method_missing(method_name, *args, &block)
            @_raw_array.send(method_name, *args, &block)
          end

          def <<(element)
            _validate_element(element) if @_validate_elements
            changed!
            @_raw_array << element
          end

          def []=(idx, element)
            _validate_element(element) if @_validate_elements
            changed!
            @_raw_array[idx] = element
          end

          def clear
            @_raw_array = []
            self
          end

          def collect!(&block)
            changed!
            @_raw_array.collect!(&block)
            self
          end

          def compact!
            result = @_raw_array.compact!
            return nil if result.nil?
            changed!
            self
          end

          def concat(*args)
            changed!
            @_raw_array.concat(*args)
            self
          end

          def delete(element, &block)
            result = @_raw_array.delete(element, &block)
            changed!
            result
          end

          def delete_at(idx)
            result = @_raw_array.delete_at(idx)
            return nil if result.nil?
            changed!
            result
          end

          def delete_if(&block)
            @_raw_array.delete_if(&block)
            changed!
            self
          end

          def fill(*args, &block)
            @_raw_array.fill(*args, &block)
            changed!
            self
          end

          def filter!(&block)
            result = @_raw_array.filter!(&block)
            return nil if result.nil?
            changed!
            self
          end

          def flatten!(level = nil)
            result = @_raw_array.flatten!(level)
            return nil if result.nil?
            changed!
            self
          end

          def insert(*args)
            @_raw_array.insert(*args)
            changed!
            self
          end

          def keep_if(&block)
            @_raw_array.keep_if(&block)
            changed!
            self
          end

          def map!(&block)
            @_raw_array.map!(&block)
            changed!
            self
          end

          def pop(n = nil)
            result = @_raw_array.pop(n)
            changed!
            result
          end

          def push(*elements)
            if @_validate_elements
              elements.each { |element| _validate_element(element) }
            end
            @_raw_array.push(*elements)
            changed!
            self
          end
          alias append push

          def reject!(&block)
            result = @_raw_array.reject!(&block)
            return nil if result.nil?
            changed!
            self
          end

          def reverse!
            @_raw_array.reverse!
            changed!
            self
          end

          def rotate!(count = 1)
            @_raw_array.rotate!(count)
            changed!
            self
          end

          def select!(&block)
            result = @_raw_array.select!(&block)
            return nil if result.nil?
            changed!
            self
          end

          def shift(n = nil)
            result = @_raw_array.shift(n)
            changed!
            result
          end

          def shuffle!(*args)
            @_raw_array.shuffle!(*args)
            changed!
            self
          end

          def slice!(*argsk)
            result = @_raw_array.slice!(*args)
            changed!
            result
          end

          def sort!(&block)
            @_raw_array.sort!(&block)
            changed!
            self
          end

          def sort_by!(&block)
            @_raw_array.sort_by!(&block)
            changed!
            self
          end

          def uniq!(&block)
            @_raw_array.uniq!(&block)
            changed!
            self
          end

          def unshift(*args)
            @_raw_array.unshift(*args)
            changed!
            self
          end
          alias prepend unshift
        end  # RUBY_ENGINE
      end
    end
  end
end
