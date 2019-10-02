module Isomorfeus
  # available settings
  class << self
    # def cached_array_classes
    #   @cached_array_classes ||= {}
    # end
    #
    # def cached_array_class(class_name)
    #   return cached_array_classes[class_name] if cached_array_classes.key?(class_name)
    #   cached_array_classes[class_name] = "::#{class_name}".constantize
    # end

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

    def cached_composable_graph_classes
      @cached_composable_graph_classes ||= {}
    end

    def cached_composable_graph_class(class_name)
      return cached_composable_graph_classes[class_name] if cached_composable_graph_classes.key?(class_name)
      cached_composable_graph_classes[class_name] = "::#{class_name}".constantize
    end

    def cached_hash_classes
      @cached_hash_classes ||= {}
    end

    def cached_hash_class(class_name)
      return cached_hash_classes[class_name] if cached_hash_classes.key?(class_name)
      cached_hash_classes[class_name] = "::#{class_name}".constantize
    end

    def cached_node_classes
      @cached_node_classes ||= {}
    end

    def cached_node_class(class_name)
      return cached_node_classes[class_name] if cached_node_classes.key?(class_name)
      cached_node_classes[class_name] = "::#{class_name}".constantize
    end

    if RUBY_ENGINE != 'opal'
      def valid_storable_object_class_names
        @valid_array_class_names ||= Set.new
      end

      def valid_storable_object_class_name?(class_name)
        valid_array_class_names.include?(class_name)
      end

      def add_valid_storable_object_class(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        valid_array_class_names << class_name
      end

      def valid_generic_collection_class_names
        @valid_generic_collection_class_names ||= Set.new
      end

      def valid_generic_collection_class_name?(class_name)
        valid_generic_collection_class_names.include?(class_name)
      end

      def add_valid_generic_collection_class(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        valid_generic_collection_class_names << class_name
      end

      def valid_graph_class_names
        @valid_graph_class_names ||= Set.new
      end

      def valid_graph_class_name?(class_name)
        valid_graph_class_names.include?(class_name)
      end

      def add_valid_graph_class(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        valid_graph_class_names << class_name
      end

      def valid_hash_class_names
        @valid_hash_class_names ||= Set.new
      end

      def valid_hash_class_name?(class_name)
        valid_hash_class_names.include?(class_name)
      end

      def add_valid_hash_class(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        valid_hash_class_names << class_name
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
        unless Arango.current_server.database_exist?(database)
          begin
            Arango.current_server.create_database(database)
          rescue Exception => e
            raise "Can't create database '#{database}' (#{e.message}).\nPlease make sure database '#{database}' exists."
          end
        end
        begin
          Arango.current_server.get_database(database)
        rescue Exception => e
          raise "Can't connect to database '#{database}' (#{e.message})."
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
    end
  end
end
