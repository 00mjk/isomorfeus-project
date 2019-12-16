module LucidChannel
  module Mixin
    def self.included(base)

      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_channel_class(base) unless base == LucidChannel::Base
      end

      base.instance_exec do
        def process_message(channel, message = nil)
          if @message_processor
            if channel == self.name
              @message_processor.call(message)
            else
              @message_processor.call(channel, message)
            end
          else
            puts "#{self} received: #{channel} #{message}, but no 'on_message' block defined!"
          end
        end

        def on_message(&block)
          @message_processor = block
        end

        def send_message(channel, message = nil)
          unless message
            message = channel
            channel = self.name
          end
          Isomorfeus::Transport.send_notification(self, channel, message)
        end

        def subscribe(channel = nil)
          channel = channel ? channel : self.name
          Isomorfeus::Transport.subscribe(self, channel)
        end

        def unsubscribe(channel = nil)
          channel = channel ? channel : self.name
          Isomorfeus::Transport.unsubscribe(self, channel)
        end
      end
    end
  end
end
