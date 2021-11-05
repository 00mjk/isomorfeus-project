class LucidQueryResult
  attr_reader :key

  def sid
    [@class_name, @key]
  end

  def sid_s
    "[#{@class_name}|#{@key}]"
  end

  if RUBY_ENGINE == 'opal'
    def initialize(key: nil, result_set: {})
      @class_name = 'LucidQueryResult'
      @key = key ? key.to_s : self.object_id.to_s
      @result_set = result_set
    end

    def _load_from_store!
      @result_set = nil
    end

    def loaded?
      Redux.fetch_by_path(:data_state, @class_name, @key) ? true : false
    end

    def key?(k)
      if @result_set
        @result_set.key?(k)
      else
        stored_results = Redux.fetch_by_path(:data_state, @class_name, @key)
        return false unless stored_results
        `Object.hasOwnProperty(stored_results, k)`
      end
    end
    alias has_key? key?

    def result_set=(r)
      @result_set = r
    end

    def method_missing(accessor_name, *args, &block)
      sid = if @result_set
              @result_set[accessor_name]
            else
              stored_results = Redux.fetch_by_path(:data_state, @class_name, @key)
              stored_results.JS[accessor_name] if stored_results
            end
      Isomorfeus.raise_error(message: "#{@class_name}: no such thing '#{accessor_name}' in the results!") unless sid
      Isomorfeus.instance_from_sid(sid)
    end
  else
    def initialize(key: nil, result_set: {})
      @class_name = 'LucidQueryResult'
      @key = key ? key.to_s : self.object_id.to_s
      @result_set = result_set.nil? ? {} : result_set
      @result_set.transform_keys!(&:to_sym)
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
      Isomorfeus.raise_error(message: "#{@class_name}: no such thing '#{accessor_name}' in the results!") unless @result_set.key?(accessor_name)
      @result_set[accessor_name]
    end

    def to_transport
      sids_hash = {}
      @result_set.each do |key, value|
        sids_hash[key.to_s] = value.sid
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
