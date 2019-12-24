module LucidData
  class QueryResult
    attr_reader :key

    def to_sid
      [@class_name, @key]
    end

    if RUBY_ENGINE == 'opal'
      def initialize(key: nil, result_set: {})
        @class_name = 'LucidData::QueryResult'
        @key = key ? key.to_s : self.object_id.to_s
        @result_set = result_set
      end

      def _load_from_store!
        @result_set = nil
      end

      def loaded?
        Redux.fetch_by_path([:data_state, @class_name, @key]) ? true : false
      end

      def key?(k)
        if @result_set.any?
          @result_set.key?(k)
        else
          stored_results = Redux.fetch_by_path([:data_state, @class_name, @key])
          `Object.hasOwnProperty(stored_results, k)`
        end
      end
      alias has_key? key?

      def result_set=(r)
        @result_set = r
      end

      def method_missing(accessor_name, *args, &block)
        raise "#{@class_name}: no such thing '#{accessor_name}‘in the results!" unless @result_set.key?(accessor_name)
        sid = if @result_set.any?
                @result_set[accessor_name]
              else
                stored_results = Redux.fetch_by_path([:data_state, @class_name, @key])
                stored_results.JS[accessor_name]
              end
        Isomorfeus.instance_from_sid(sid)
      end
    else
      def initialize(key: nil, result_set: {})
        @class_name = 'LucidData::QueryResult'
        @key = key ? key.to_s : self.object_id.to_s
        @result_set = result_set
      end

      def loaded?
        @result_set.any?
      end

      def key?(k)
        @result_set.key?(k)
      end
      alias has_key? key?

      def result_set=(r)
        @result_set = r
      end

      def method_missing(accessor_name, *args, &block)
        raise "#{@class_name}: no such thing '#{accessor_name}‘in the results!" unless @result_set.key?(accessor_name)
        @result_set[accessor_name]
      end

      def to_transport
        sids_hash = {}
        @result_set.each do |key, value|
          sids_hash[key] = value.to_sid
        end
        { @class_name => { @key => sids_hash }}
      end

      def included_items_to_transport
        data_hash = {}
        @result_set.each_value do |value|
          data_hash.deep_merge!(value.to_transport)
          if value.respond_to?(:included_items_to_transport)
            data_hash.deep_merge!(value.included_items_to_transport)
          end
        end
        data_hash
      end
    end
  end
end
