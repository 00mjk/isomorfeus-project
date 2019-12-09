module LucidData
  module Document
    module Mixin
      def self.included(base)
        base.extend(LucidPropDeclaration::Mixin)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)

        base.instance_exec do
          def attribute_conditions
            @attribute_conditions ||= {}
          end

          def valid_attribute?(attr_name, attr_value)
            Isomorfeus::Props::Validator.new(self.name, attr_name, attr_value, attribute_conditions[attr_name]).validate!
          rescue
            false
          end
        end

        def _validate_attribute(attr_name, attr_val)
          raise "No such attribute declared: '#{attr_name}'!" unless self.class.attribute_conditions.key?(attr_name)
          Isomorfeus::Props::Validator.new(@class_name, attr_name, attr_val, self.class.attribute_conditions[attr_name]).validate!
        end

        if RUBY_ENGINE == 'opal'
          base.instance_exec do
            def attribute(name, options = {})
              attribute_conditions[name] = options

              define_method(name) do
                _get_attribute(name)
              end

              define_method("#{name}=") do |val|
                _validate_attribute(name, val)
                @_changed_attributes[name] = val
              end
            end
          end

          def initialize(key:, revision: nil, attributes: nil, graph: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_graph = graph
            @_store_path = [:data_state, @class_name, @key]
            @_revision_store_path = [:data_state, :revision, @class_name, @key]
            @_revision = revision ? revision : Redux.fetch_by_path(*@_revision_store_path)
            loaded = loaded?
            if attributes
              attributes.each { |a,v| _validate_attribute(a, v) }
              if loaded
                raw_attributes = Redux.fetch_by_path(*@_store_path)
                if `raw_attributes === null`
                  @_changed_attributes = !attributes ? {} : attributes
                elsif raw_attributes && !attributes.nil? && Hash.new(raw_attributes) != attributes
                  @_changed_attributes = attributes
                end
              else
                @_changed_attributes = attributes
              end
            else
              @_changed_attributes = {}
            end
          end

          def _get_attribute(name)
            return @_changed_attributes[name] if @_changed_attributes.key?(name)
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

          def _load_from_store!
            @_changed_attributes = {}
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
            _get_attribute(name)
          end

          def []=(name, val)
            _validate_attribute(name, val)
            @_changed_attributes[name] = val
          end

          def to_transport
            hash = _get_attributes
            rev = revision
            hash.merge!(_revision: rev) if rev
            { @class_name => { @key => hash }}
          end
        else # RUBY_ENGINE
          unless base == LucidData::Document::Base
            Isomorfeus.add_valid_data_class(base)
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end

          base.attr_accessor :collection

          base.instance_exec do
            def load(key:, pub_sub_client: nil, current_user: nil)
              data = instance_exec(key: key, &@_load_block)
              revision = nil
              revision = data.delete(:_revision) if data.key?(:_revision)
              revision = data.delete(:revision) if !revision && data.key?(:revision)
              data.delete(:_key)
              attributes = data.key?(:attributes) ? data.delete(:attributes) : data
              self.new(key: key, revision: revision, attributes: attributes)
            end

            def attribute(name, options = {})
              attribute_conditions[name] = options

              define_method(name) do
                @_raw_attributes[name]
              end

              define_method("#{name}=") do |val|
                _validate_attribute(name, val)
                @_changed = true
                @_raw_attributes[name] = val
              end
            end
          end

          def initialize(key:, revision: nil, attributes: nil, collection: collection)
            @key = key.to_s
            @_revision = revision
            @_changed = false
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @collection = collection
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
            _validate_attribute(name, val)
            @_changed = true
            @_raw_attributes[name] = val
          end

          def method_missing(method_name, *args, &block)
            if collection&.graph
              node_matrix = collection.graph._get_node_matrix([@class_name, @key])
              singular_name = method_name.singularize
              plural_name = method_name.pluralize
              if method_name == plural_name
                # return all nodes that match
                nodes = []
                node_matrix.each do |node_edge|
                  if node_edge[0] == singular_name
                    # node match
                    nodes < node_edge[1]
                  end
                end
              elsif method_name == singular_name
                # return one node
                node_matrix.each do |node_edge|
                  if node_edge[0] == singular_name
                    # node match
                    return node_edge[1]
                  end
                end
              end
            end
          end

          def to_transport
            hash = {}
            self.class.attribute_conditions.each do |attr, options|
              if !options[:server_only] && @_raw_attributes.key?(attr)
                hash[attr.to_s] = @_raw_attributes[attr]
              end
            end
            hash.merge!("_revision" => revision) if revision
            { @class_name => { @key => hash }}
          end
        end # RUBY_ENGINE
      end
    end
  end
end
