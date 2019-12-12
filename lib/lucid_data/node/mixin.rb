module LucidData
  module Node
    module Mixin
      def self.included(base)
        base.extend(LucidPropDeclaration::Mixin)
        base.include(Isomorfeus::Data::AttributeSupport)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)

        def changed?
          @_changed
        end

        def changed!
          @_collection.changed! if @_collection
          @_composition.changed! if @_composition
          @_changed = true
        end

        def collection
          @_collection
        end

        def collection=(c)
          @_collection = c
        end

        def graph
          @_collection&.graph
        end

        def composition
          @_composition
        end

        def composition=(c)
          @_composition = c
        end

        def revision
          @_revision
        end

        def edges
          graph&.edges_for_node(self)
        end

        def linked_nodes
          graph&.linked_nodes_for_node(self)
        end

        def method_missing(method_name, *args, &block)
          if graph
            method_name_s = method_name.to_s
            singular_name = method_name_s.singularize
            plural_name = method_name_s.pluralize
            node_edges = edges
            if method_name_s == plural_name
              # return all nodes
              nodes = []
              sid = to_sid
              node_edges.each do |edge|
                from_sid = edge.from_as_sid
                to_sid = edge.to_as_sid
                node = if from_sid[0].underscore == singular_name && to_sid == sid
                         edge.from
                       elsif to_sid[0].underscore == singular_name && from_sid == sid
                         edge.to
                       end
                nodes << node if node
              end
              return nodes
            elsif method_name_s == singular_name
              # return one node
              sid = to_sid
              node_edges.each do |edge|
                from_sid = edge.from_as_sid
                to_sid = edge.to_as_sid
                node = if from_sid[0].underscore == singular_name && to_sid == sid
                         edge.from
                       elsif to_sid[0].underscore == singular_name && from_sid == sid
                         edge.to
                       end
                return node if node
              end
              nil
            end
          else
            super(method_name, *args, &block)
          end
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, attributes: nil, graph: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_store_path = [:data_state, @class_name, @key]
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, :revision, @class_name, @key)
            @_graph = graph
            @_composition = composition
            @_changed = false
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

          def _load_from_store!
            @_changed_attributes = {}
            @_changed = false
          end

          def each(&block)
            _get_attributes.each(&block)
          end

          def [](name)
            _get_attribute(name)
          end

          def []=(name, val)
            _validate_attribute(name, val)
            changed!
            @_changed_attributes[name] = val
          end

          def to_transport
            hash = _get_attributes
            rev = revision
            hash.merge!(_revision: rev) if rev
            { @class_name => { @key => hash }}
          end
        else # RUBY_ENGINE
          unless base == LucidData::Node::Base || base == LucidData::Document::Base || base == LucidData::Vertex::Base
            Isomorfeus.add_valid_data_class(base)
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end

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
          end

          def initialize(key:, revision: nil, attributes: nil, collection: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_composition = composition
            @_collection = collection
            @_changed = false
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
            _validate_attribute(name, val)
            changed!
            @_raw_attributes[name] = val
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
