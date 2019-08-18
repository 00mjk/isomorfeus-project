module Isomorfeus
  module Data
    class Props
      def initialize(props_hash)
        props_hash = {} unless props_hash
        @props_hash = props_hash
      end

      def any?
        @props_hash.keys.size > 0
      end

      if RUBY_ENGINE == 'opal'
        def [](prop_name)
          @props_hash[prop_name]
        end

        def []=(prop_name, value)
          @props_hash[prop_name] = value
        end

        def key?(prop_name)
          @props_hash.key?(prop_name)
        end

        def keys
          @props_hash.keys
        end

        def method_missing(prop_name, *args, &block)
          return @props_hash[prop_name] if @props_hash.key?(prop_name)
          super(prop_name, *args, &block)
        end

        def set(prop_name, value)
          @props_hash[prop_name] = value
        end

        def to_json
          JSON.dump(to_transport)
        end

        def to_transport
          transport_hash = {}.merge(@props_hash)
          transport_hash
        end
      else # RUBY_ENGINE
        def [](prop_name)
          name = prop_name.to_sym
          return @props_hash[name] if @props_hash.key?(name)
          name = prop_name.to_s
          return @props_hash[name] if @props_hash.key?(name)
          nil
        end

        def []=(prop_name, value)
          @props_hash[prop_name.to_sym] = value
        end

        def key?(prop_name)
          @props_hash.key?(prop_name.to_sym) || @props_hash.key?(prop_name.to_s)
        end

        def keys
          @props_hash.keys.map(&:to_sym)
        end

        def method_missing(prop_name, *args, &block)
          name = prop_name.to_sym
          return @props_hash[name] if @props_hash.key?(name)
          name = prop_name.to_s
          return @props_hash[name] if @props_hash.key?(name)
          super(prop_name, *args, &block)
        end

        def set(prop_name, value)
          @props_hash[prop_name.to_sym] = value
        end

        def to_json
          Oj.dump(to_transport, mode: :strict)
        end

        def to_transport
          transport_hash = {}.merge(@props_hash)
          transport_hash.delete(:pub_sub_client)
          transport_hash.delete(:current_user)
          transport_hash
        end
      end # RUBY_ENGINE

      alias_method :has_key?, :key?
    end
  end
end
