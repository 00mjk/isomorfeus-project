module LucidData
  module File
    module ClassApi
      if RUBY_ENGINE == 'opal'
        def plugin(*args, &block)
        end

        def derivatives(*args, &block)
        end

        def validate(*args, &block)
        end

        def promote_block(&block)
        end

        def destroy_block(&block)
        end

        def destroy(key:)
          promise_destroy(key: key)
          true
        end

        def promise_destroy(key:)
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::File', self.name, :destroy, key: key).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              Isomorfeus.store.dispatch(type: 'DATA_DESTROY', data: [self.name, key])
              agent.result = true
            end
          end
        end

        def load(key:, variant: nil, variants: nil, derivative: nil, derivatives: nil)
          instance = self.new(key: key, type: type)
          promise_load(key: key, variant: variant, variants: variants, derivative: derivative, derivatives: derivatives, instance: instance) unless instance.loaded?
          instance
        end

        def promise_load(key:, variant: nil, variants: nil, derivative: nil, derivatives: nil, instance: nil)
          instance = self.new(key: key, variant: variant, variants: variants, derivative: derivative, derivatives: derivatives) unless instance
          if instance.loaded?
            Promise.new.resolve(instance)
          else
            promise_load!(key: key, variant: variant, variants: variants, derivative: derivative, derivatives: derivatives, instance: instance)
          end
        end

        def load!(key:, variant: nil, variants: nil, derivative: nil, derivatives: nil)
          instance = self.new(key: key, type: type)
          promise_load!(key: key, variant: variant, variants: variants, derivative: derivative, derivatives: derivatives, instance: instance) unless instance.loaded?
          instance
        end

        def promise_load!(key:, variant: nil, variants: nil, derivative: nil, derivatives: nil, instance: nil)
          instance = self.new(key: key, type: type) unless instance
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::File', self.name, :load, key: key).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              instance._load_from_store!
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
              agent.result = instance
            end
          end
        end

        # execute
        def execute_create(_); end
        def execute_destroy(_); end
        def execute_load(_); end
        def execute_save(_); end
      else
        def plugin(*args, &block)
          const_get("Uploader").plugin(*args, &block)
        end

        def derivatives(*args, &block)
          const_get("Uploader").const_get("Attacher").derivatives(*args, &block)
        end

        def validate(*args, &block)
          const_get("Uploader").const_get("Attacher").validate(*args, &block)
        end

        def promote_block(&block)
          const_get("Uploader").const_get("Attacher").promote_block(&block)
        end

        def destroy_block(&block)
          const_get("Uploader").const_get("Attacher").destroy_block(&block)
        end

        def add_metadata(*args, &block)
          const_get("Uploader").const_get("Attacher").add_metadata(*args, &block)
        end

        def default_cache(d)
          @default_cache = d
        end

        def default_store(d)
          @default_store = d
        end

        # standard lucid api
        def destroy(key:)
          if @_destroy_block
            !!instance_exec(key: key, &@_destroy_block)
          else
            store_key = instance_variable_get(:@default_store)
            store = Shrine.storages[store_key]
            store.delete(key)
            true
          end
        end

        def load(key:, variant: nil, variants: nil, derivative: nil, derivatives: nil)
          if @_load_block
            data = instance_exec(key: key, variant: variant, variants: variants, derivative: derivative, derivatives: derivatives, &@_load_block)
          else
            store_key = instance_variable_get(:@default_store)
            store = Shrine.storages[store_key]
            file = store.open(key)
            result_derivatives = {}

            derivatives = [derivative] if derivative
            variants = [variant] if variant

            v = variants.delete(:url)
            if v
              if derivatives
                derivatives.each do |d|
                  result_derivatives[d] = {} unless result_derivatives.key?(d)
                  result_derivatives[d][:url] = "#{Isomorfeus.file_request_path}/#{self.to_s}/#{d}/#{key}"
                end
              else
                result_derivatives[d][:default] = { url: "#{Isomorfeus.file_request_path}/#{self.to_s}/#{key}" }
              end
            end

            v = variants.delete(:data_url)
            if v
              if derivatives
                derivatives.each do |d|
                  result_derivatives[d] = {} unless result_derivatives.key?(d)
                  result_derivatives[d][:data_url] = file.image_derivative[derivative].image_data_uri
                end
              else
                result_derivatives[d][:default] = { data_url: file.image_data_uri }
              end
            end

            v = variants.delete(:data)
            if v
              if derivatives
                derivatives.each do |d|
                  result_derivatives[d] = {} unless result_derivatives.key?(d)
                  result_derivatives[d][:data] = file.image_derivative[derivative].read
                end
              else
                result_derivatives[d][:default] = { data: file.read }
              end
            end

            data = new(key: key, derivatives: result_derivatives)

          end
          return nil unless data
          return data if data.class == self
          Isomorfeus.raise_error(message: "#{self.to_s}: execute_load must return a instance of #{self.to_s} or nil. Returned was: #{data.class}.") if data.class != self
          data
        end
        alias load! load

        def promise_load(key:, variant: nil, variants: nil, derivative: nil, derivatives: nil, instance: nil)
          instance = self.load(key: key, variant: variant, variants: variants, derivative: derivative, derivatives: derivatives)
          result_promise = Promise.new
          result_promise.resolve(instance)
          result_promise
        end
        alias promise_load! promise_load

        # execute
        def execute_create(&block)
          @_create_block = block
        end

        def execute_destroy(&block)
          @_destroy_block = block
        end

        def execute_load(&block)
          @_load_block = block
        end

        def execute_save(&block)
          @_save_block = block
        end
      end

      def create(key:, **things)
        new(key: key, **things).create
      end

      def promise_create(key:, **things)
        new(key: key, **things).promise_create
      end

      def save(instance:)
        instance.save
      end

      def promise_save(instance:)
        instance.promise_save
      end

      def current_user
        Isomorfeus.current_user
      end

      def pub_sub_client
        Isomorfeus.pub_sub_client
      end
    end
  end
end
