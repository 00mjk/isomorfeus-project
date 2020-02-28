module LucidChannel
  module Mixin
    def self.included(base)
      Isomorfeus.add_valid_channel_class(base) unless base == LucidChannel::Base

      base.instance_exec do
        def subscription_channels
          @subscription_channels ||= {}
        end

        def channel(name, options = {})
          subscription_channels[name.to_s] = options
        end

        def valid_channel?(name)
          name = name.to_s
          subscription_channels.key?(name) || name == self.name
        end

        def process_message(message, error, channel = nil)
          channel = self.name unless channel
          channel = channel.to_s
          unless valid_channel?(channel)
            Isomorfeus.raise_error(message: "No such channel '#{channel}' declared for #{self.name}! Cannot process message")
          end
          block = subscription_channels[channel][:block]
          Isomorfeus.raise_error(message: "#{self} received: #{channel} #{message}, but no 'on_message' block defined!") unless block
          block.call(message, error)
          nil
        end

        def on_message(channel = nil, &block)
          channel = self.name unless channel
          channel = channel.to_s
          unless valid_channel?(channel)
            Isomorfeus.raise_error(message: "No such channel #{channel} declared, please declare it first!")
          end
          subscription_channels[channel] = {} unless subscription_channels.key?(channel)
          subscription_channels[channel][:block] = block
        end

        def send_message(message, channel = nil)
          channel = self.name unless channel
          unless valid_channel?(channel)
            Isomorfeus.raise_error(message: "No such channel '#{channel}' declared for #{self.name}! Cannot send message")
          end
          Isomorfeus::Transport.send_message(self, channel, message)
        end

        def subscribe(channel = nil)
          promise_subscribe(channel)
          nil
        end

        def promise_subscribe(channel = nil)
          channel = channel ? channel : self.name
          Isomorfeus::Transport.promise_subscribe(self.name, channel)
        end

        def unsubscribe(channel = nil)
          promise_unsubscribe(channel)
          nil
        end

        def promise_unsubscribe(channel = nil)
          channel = channel ? channel : self.name
          Isomorfeus::Transport.promise_unsubscribe(self.name, channel)
        end

        if RUBY_ENGINE == 'opal'
          def server_subscription_channels; end
          def server_process_message(message, channel = nil); end
          def server_on_message(channel = nil, &block); end
        else
          def server_is_processing_messages?(channel)
            return false if server_subscription_channels.empty?
            return true if server_subscription_channels.key?(channel) && server_subscription_channels[channel].key?(:block)
            false
          end

          def server_subscription_channels
            @server_subscription_channels ||= {}
          end

          def server_process_message(message, channel = nil)
            channel = self.name unless channel
            channel = channel.to_s
            block = server_subscription_channels[channel][:block]
            block.call(message)
          end

          def server_on_message(channel = nil, &block)
            channel = self.name unless channel
            channel = channel.to_s
            unless valid_channel?(channel)
              Isomorfeus.raise_error(message: "No such channel #{channel} declared, please declare it first!")
            end
            server_subscription_channels[channel] = {} unless server_subscription_channels.key?(channel)
            server_subscription_channels[channel][:block] = block
          end
        end
      end
    end
  end
end
