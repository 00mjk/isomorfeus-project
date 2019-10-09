module Isomorfeus
  # available settings
  class << self
    def cached_composable_graph_classes
      @cached_composable_graph_classes ||= {}
    end

    def cached_composable_graph_class(class_name)
      return cached_composable_graph_classes[class_name] if cached_composable_graph_classes.key?(class_name)
      cached_composable_graph_classes[class_name] = "::#{class_name}".constantize
    end

    def cached_generic_collection_classes
      @cached_generic_collection_classes ||= {}
    end

    def cached_generic_collection_class(class_name)
      return cached_generic_collection_classes[class_name] if cached_generic_collection_classes.key?(class_name)
      cached_generic_collection_classes[class_name] = "::#{class_name}".constantize
    end

    def cached_generic_edge_classes
      @cached_generic_edge_classes ||= {}
    end

    def cached_generic_edge_class(class_name)
      return cached_generic_edge_classes[class_name] if cached_generic_edge_classes.key?(class_name)
      cached_generic_edge_classes[class_name] = "::#{class_name}".constantize
    end

    def cached_generic_node_classes
      @cached_generic_node_classes ||= {}
    end

    def cached_generic_node_class(class_name)
      return cached_generic_node_classes[class_name] if cached_generic_node_classes.key?(class_name)
      cached_generic_node_classes[class_name] = "::#{class_name}".constantize
    end

    if RUBY_ENGINE != 'opal'
      def valid_storable_object_class_names
        @valid_array_class_names ||= Set.new
      end

      def valid_storable_object_class_name?(class_name)
        valid_array_class_names.include?(class_name)
      end

      def add_valid_storable_object_class(klass)
        valid_array_class_names << data_class_name(klass)
      end

      def valid_generic_collection_class_names
        @valid_generic_collection_class_names ||= Set.new
      end

      def valid_generic_collection_class_name?(class_name)
        valid_generic_collection_class_names.include?(class_name)
      end

      def add_valid_generic_collection_class(klass)
        valid_generic_collection_class_names << data_class_name(klass)
      end

      def valid_composable_graph_class_names
        @valid_composable_graph_class_names ||= Set.new
      end

      def valid_composable_graph_class_name?(class_name)
        valid_composable_graph_class_names.include?(class_name)
      end

      def add_valid_composable_graph_class(klass)
        valid_composable_graph_class_names << data_class_name(klass)
      end

      def valid_generic_edge_class_names
        @valid_generic_edge_class_names ||= Set.new
      end

      def valid_generic_edge_class_name?(class_name)
        valid_generic_edge_class_names.include?(class_name)
      end

      def add_valid_generic_edge_class(klass)
        valid_generic_edge_class_names << data_class_name(klass)
      end

      def valid_generic_node_class_names
        @valid_generic_node_class_names ||= Set.new
      end

      def valid_generic_node_class_name?(class_name)
        valid_generic_node_class_names.include?(class_name)
      end

      def add_valid_generic_node_class(klass)
        valid_generic_node_class_names << data_class_name(klass)
      end

      def connect_to_arango
        arango_options = if Isomorfeus.production? then Isomorfeus.arango_production
                         elsif Isomorfeus.development? then Isomorfeus.arango_development
                         elsif Isomorfeus.test? then Isomorfeus.arango_test
                         end
        arango_options = {}.merge(arango_options)
        database = arango_options.delete(:database)
        Arango.connect_to(**arango_options)
        begin
          Arango.current_server.get_database(database)
        rescue Exception => e
          raise "Can't connect to database '#{database}' (#{e.message})."
        end
      end

      def prepare_arango_database
        arango_options = if Isomorfeus.production? then Isomorfeus.arango_production
                         elsif Isomorfeus.development? then Isomorfeus.arango_development
                         elsif Isomorfeus.test? then Isomorfeus.arango_test
                         end
        arango_options = {}.merge(arango_options)
        database = arango_options.delete(:database)
        Arango.connect_to(**arango_options)
        db = nil
        begin
          opened_db = Arango.current_server.get_database(database)
          db = opened_db.name
        rescue Exception => e
          db = nil
          unless e.message.include?('database not found')
            raise "Can't check if database '#{database}' exists."
          end
        end
        unless db
          begin
            Arango.current_server.create_database(database)
          rescue Exception => e
            raise "Can't create database '#{database}' (#{e.message}).\nPlease make sure database '#{database}' exists."
          end
          begin
            Arango.current_server.get_database(database)
          rescue Exception => e
            raise "Can't connect to database '#{database}' (#{e.message})."
          end
        end

        Arango.current_server.install_opal_module(database)
        unless Arango.current_database.collection_exist?('IsomorfeusSessions')
          Arango.current_database.create_collection('IsomorfeusSessions')
        end
        unless Arango.current_database.collection_exist?('IsomorfeusObjectStore')
          Arango.current_database.create_collection('IsomorfeusObjectStore')
        end
      end

      def arango_configured?
        !!(Isomorfeus.arango_production && Isomorfeus.arango_development && Isomorfeus.arango_test)
      end

      attr_accessor :arango_production
      attr_accessor :arango_development
      attr_accessor :arango_test

      private

      def data_class_name(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        class_name
      end
    end
  end
end
