module LucidArray < Array
  if RUBY_ENGINE == 'opal'
    def self.inherited(base)
      base.extend(LucidPropDeclaration::Mixin)

      base.instance_exec do
        def arrays
          @arrays ||= {}
        end

        def unload(key)
          @array.delete(key)
        end

        def new(array, key)
          return arrays[key] if arrays.key?(key)
          super(array, key)
        end

        def promise_load(key, props_hash = {})
          validate_props(props_hash)

          props_json = JSON.dump(props_hash)

          Isomorfeus::Transport.promise_send_path('Isomorfeus::Data::Handler::Generic', 'load', 'Array', self.name, key, props_json).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                `console.error(#{agent.response[:error].to_n})`
                raise agent.response[:error]
              end
              instance = self.new(agent.full_response[:data], key)
              instance.dispatch_changes
              agent.result = instance
            end
          end
        end

        def load(key, props_hash = {})
          validate_props(props_hash)
          return arrays[key] if arrays.key?(key)
          instance = self.new([], key)
          self.promise_load(key, props_hash)
          instance
        end

        def load_query_block
        end

        def load_query(&block)
        end

        def on_load(&block)
        end

        def destroy_query_block
        end

        def destroy_query(&block)
        end

        def on_destroy(&block)
        end

        def store_query_block
        end

        def store_query(&block)
        end

        def on_store(&block)
        end
      end
    end

    def initialize(array, key)
      super(array)
      @key = key
      @class_name = self.class.name
      @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
      @store_path = [:data_state, :arrays, @class_name, @key]
      @iteration = 0
      self.class.arrays[@key] = self
    end

    def dispatch_changes
      Isomorfeus.store.merge_and_defer_dispatch(type: 'DATA_LOAD', data: { arrays: { @class_name => { @key => @iteration += 1 }}})
    end

    def loaded?
      Redux.fetch_by_path(*@store_path) ? true : false
    end

    def promise_destroy
      Isomorfeus::Transport.promise_send_path('Isomorfeus::Data::Handler::Generic', 'destroy', 'Array', self.name, key).then do |agent|
        if agent.processed
          agent.result
        else
          agent.processed = true
          if agent.response.key?(:error)
            `console.error(#{agent.response[:error].to_n})`
            raise agent.response[:error]
          end
          self.class.unload(@key)
          agent.result = nil
        end
      end
    end

    def destroy
      promise_destroy
      nil
    end

    def promise_store
      Isomorfeus::Transport.promise_send_path('Isomorfeus::Data::Handler::Generic', 'store', 'Array', self.name, key).then do |agent|
        if agent.processed
          agent.result
        else
          agent.processed = true
          if agent.response.key?(:error)
            `console.error(#{agent.response[:error].to_n})`
            raise agent.response[:error]
          end
          agent.result = true
        end
      end
    end

    def store
      promise_store
      nil
    end

    def to_cid
      [@class_name, @key]
    end

    def to_transport(inline: false)
      first_key = inline ? '_inline' : 'arrays'
      { first_key => { @class_name => { @key => self }}}
    end

    # Array instance methods that now require a dispatch

    def <<(obj)
      super(obj)
      dispatch_changes
      self
    end

    def []=(*args)
      result = super(*args)
      dispatch_changes
      result
    end

    def clear
      super
      dispatch_changes
      self
    end

    def collect!(&block)
      result = super(&block)
      dispatch_changes
      result
    end

    def compact!
      result = super
      dispatch_changes if result
      result
    end

    def concat(*args)
      super(*args)
      dispatch_changes
      self
    end

    def delete(obj, &block)
      result = super(obj, &block)
      dispatch_changes if result
      result
    end

    def delete_at(obj)
      result = super(obj)
      dispatch_changes if result
      result
    end

    def delete_if(&block)
      result = super(&block)
      dispatch_changes
      result
    end

    def drop(n)
      result = super(n)
      dispatch_changes
      result
    end

    def drop_while(&block)
      result = super(&block)
      dispatch_changes
      result
    end

    def fill(*args)
      super(*args)
      dispatch_changes
      self
    end

    def filter!(&block)
      result = super(&block)
      dispatch_changes
      result
    end

    def flatten!(*args)
      result = super(*args)
      dispatch_changes if result
      result
    end

    def initialize_copy(a)
      super(a)
      dispatch_changes
      self
    end
    alias replace initialize_copy

    def insert(*args)
      super(*args)
      dispatch_changes
      self
    end

    def keep_if(&block)
      result = super(*args)
      dispatch_changes
      result
    end

    def map!(&block)
      result = super(*args)
      dispatch_changes
      result
    end

    def pop(*args)
      result = super(*args)
      dispatch_changes
      result
    end

    def push(obj)
      super(obj)
      dispatch_changes
      self
    end
    alias append push

    def reject!(&block)
      result = super(&block)
      dispatch_changes if result
      result
    end

    def reverse!
      super
      dispatch_changes
      self
    end

    def rotate!(count = 1)
      super(count)
      dispatch_changes
      self
    end

    def select!(&block)
      result = super(&block)
      dispatch_changes if result
      result
    end

    def shift(*args)
      result = super(*args)
      dispatch_changes
      result
    end

    def shuffle!(*args)
      super(*args)
      dispatch_changes
      self
    end

    def slice!(*args)
      result = super(*args)
      dispatch_changes
      result
    end

    def sort!(&block)
      super(&block)
      dispatch_changes
      self
    end

    def sort_by!(&block)
      result = super(&block)
      dispatch_changes
      result
    end

    def uniq!(&block)
      result = super(&block)
      dispatch_changes if result
      result
    end

    def unshift(*args)
      super(*args)
      dispatch_changes
      self
    end
    alias prepend unshift
  else
    def self.inherited(base)
      base.extend(LucidPropDeclaration::Mixin)

      Isomorfeus.add_valid_array_class(base)

      base.prop :pub_sub_client, default: nil
      base.prop :current_user, default: nil

      base.instance_exec do
        def arrays
          @arrays ||= {}
        end

        def unload(key)
          @array.delete(key)
        end

        def new(array, key)
          return arrays[key] if arrays.key?(key)
          super(array, key)
        end

        def promise_load(key, props_hash = {})
          result_promise = Promise.new
          result_promise.resolve(self.load(key, props_hash))
          result_promise
        end

        def load(key, props_hash = {})
          validate_props(props_hash)
          array = self.class.load_query_block.call(props_hash)
          self.new(array, key)
        end

        def load_query_block
          @load_query
        end

        def load_query(&block)
          @load_query = block
        end

        def on_load(&block)
          @on_load = block
        end

        def destroy_query_block
          @destroy_query
        end

        def destroy_query(&block)
          @destroy_query = block
        end

        def on_destroy(&block)
          @on_destroy = block
        end

        def store_query_block
          @store_query
        end

        def store_query(&block)
          @store_query = block
        end

        def on_store(&block)
          @on_store = block
        end
      end
    end

    def initialize(array, key)
      super(array)
      @key = key
      @class_name = self.class.name
      @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
      self.class.arrays[@key] = self
    end

    def dispatch_changes
    end

    def loaded?
      true
    end

    def promise_destroy
      result_promise = Promise.new
      result_promise.resolve(destroy)
      result_promise
    end

    def destroy
      instance_exec(&self.class.destroy_query_block)
    end

    def promise_store
      result_promise = Promise.new
      result_promise.resolve(store)
      result_promise
    end

    def store
      instance_exec(&self.class.store_query_block)
    end

    def to_transport(inline: false)
      first_key = inline ? '_inline' : 'arrays'
      { first_key => { @class_name => { @key => self }}}
    end
  end
end
