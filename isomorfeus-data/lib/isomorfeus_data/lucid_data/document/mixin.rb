module LucidData
  module Document
    module Mixin
      def self.included(base)
        base.include(Isomorfeus::Data::FieldSupport)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)

        def [](name)
          send(name)
        end

        def []=(name, val)
          send(name + '=', val)
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

        def edges
          graph&.edges_for_node(self)
        end

        def linked_nodes
          graph&.linked_nodes_for_node(self)
        end

        def to_transport
          hash = { 'fields' => _get_selected_fields }
          hash['revision'] = revision if revision
          result = { @class_name => { @key => hash }}
          result.deep_merge!(@class_name => { @previous_key => { new_key: @key}}) if @previous_key
          result
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, fields: nil, collection: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            _update_paths
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, :revision, @class_name, @key)
            @_collection = collection
            @_composition = composition
            @_changed = false
            loaded = loaded?
            if fields
              if loaded
                raw_fields = Redux.fetch_by_path(*@_store_path)
                if `raw_fields === null`
                  @_changed_fields = !fields ? {} : fields
                elsif raw_fields && !fields.nil? && ::Hash.new(raw_fields) != fields
                  @_changed_fields = fields
                end
              else
                @_changed_fields = fields
              end
            else
              @_changed_fields = {}
            end
          end

          def _load_from_store!
            @_changed_fields = {}
            @_changed = false
          end

          def _update_paths
            @_store_path = [:data_state, @class_name, @key, :fields]
          end

          def each(&block)
            fields.each(&block)
          end

          def method_missing(method_name, *args, &block)
            if graph
              singular_name = `method_name.endsWith('s')` ? method_name.singularize : method_name
              node_edges = edges
              sid = sid
              camelized_singular = singular_name.camelize

              if method_name == singular_name
                # return one node
                node_edges.each do |edge|
                  from_sid = edge.from_as_sid
                  to_sid = edge.to_as_sid
                  node = if from_sid[0] == camelized_singular && to_sid == sid
                           edge.from
                         elsif to_sid[0] == camelized_singular && from_sid == sid
                           edge.to
                         end
                  return node if node
                end
                nil
              elsif method_name == method_name.pluralize
                # return all nodes
                nodes = []
                node_edges.each do |edge|
                  from_sid = edge.from_as_sid
                  to_sid = edge.to_as_sid
                  node = if from_sid[0] == camelized_singular && to_sid == sid
                           edge.from
                         elsif to_sid[0] == camelized_singular && from_sid == sid
                           edge.to
                         end
                  nodes << node if node
                end
                return nodes
              end
            else
              super(method_name, *args, &block)
            end
          end
        else # RUBY_ENGINE
          Isomorfeus.add_valid_data_class(base) unless base == LucidData::Node::Base || base == LucidData::Document::Base

          base.instance_exec do
            def instance_from_transport(instance_data, _included_items_data)
              key = instance_data[self.name].keys.first
              revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
              fields = instance_data[self.name][key].key?('fields') ? instance_data[self.name][key]['fields'].transform_keys!(&:to_sym) : nil
              new(key: key, revision: revision, fields: fields)
            end

            def setup_index(&block)
              @_setup_index_block = block
            end

            def ferret_accelerator
              return @ferret_accelerator if @ferret_accelerator
              @ferret_accelerator = if @_setup_index_block
                                      Isomorfeus::Data::FerretAccelerator.new(self, @_setup_index_block)
                                    else
                                      Isomorfeus::Data::FerretAccelerator.new(self)
                                    end
            end

            execute_create do
              self.key = SecureRandom.uuid
              doc = self.fields
              doc[:id] = self.key
              self.class.ferret_accelerator.create_doc(doc)
              self
            end

            execute_destroy do |key:|
              self.ferret_accelerator.destroy_doc(key)
            end

            execute_load do |key:|
              doc = self.ferret_accelerator.load_doc(key)
              doc.delete(:id)
              self.new(key: key, fields: doc)
            end

            execute_save do
              self.key = SecureRandom.uuid unless self.key
              doc = self.fields
              doc[:id] = self.key
              self.class.ferret_accelerator.save_doc(self.key, doc)
              self
            end
          end

          def initialize(key:, revision: nil, fields: nil, collection: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_collection = collection
            @_composition = composition
            @_changed = false
            fields = {} unless fields
            @_raw_fields = fields
          end

          def _unchange!
            @_changed = false
          end

          def each(&block)
            @_raw_fields.each(&block)
          end

          def method_missing(method_name, *args, &block)
            if graph
              method_name_s = method_name.to_s
              singular_name = method_name_s.singularize
              node_edges = edges
              sid = to_sid
              camelized_singular = singular_name.camelize

              if method_name_s == singular_name
                # return one node
                node_edges.each do |edge|
                  from_sid = edge.from_as_sid
                  to_sid = edge.to_as_sid
                  node = if from_sid[0] == camelized_singular && to_sid == sid
                           edge.from
                         elsif to_sid[0] == camelized_singular && from_sid == sid
                           edge.to
                         end
                  return node if node
                end
                nil
              elsif method_name_s == method_name_s.pluralize
                # return all nodes
                nodes = []
                node_edges.each do |edge|
                  from_sid = edge.from_as_sid
                  to_sid = edge.to_as_sid
                  node = if from_sid[0] == camelized_singular && to_sid == sid
                           edge.from
                         elsif to_sid[0] == camelized_singular && from_sid == sid
                           edge.to
                         end
                  nodes << node if node
                end
                return nodes
              end
            else
              super(method_name, *args, &block)
            end
          end
        end # RUBY_ENGINE
      end
    end
  end
end
