module LucidChannel
  module Mixin
    def self.included(base)
      base.instance_exec do
        def process_message(channel, message = nil)
          if @message_processor
            if channel == self.to_s
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
            channel = self.to_s
          end
          Isomorfeus::Transport.send_notification(self, channel, message)
        end

        def subscribe(channel = nil)
          channel = channel ? channel : self.to_s
          Isomorfeus::Transport.subscribe(channel)
        end

        def unsubscribe(channel = nil)
          channel = channel ? channel : self.to_s
          Isomorfeus::Transport.unsubscribe(channel)
        end
      end
    end
  end
end