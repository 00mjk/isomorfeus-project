module LucidChannel
  module Mixin
    def self.included(base)
      base.instance_exec do
        def process_message(message)
          if @message_processor
            @message_processor.call(message)
          else
            puts "#{self} received: #{message}, but no processor defined!"
          end
        end

        def on_message(&block)
          @message_processor = block
        end

        def send_message(message)
          Isomorfeus::Transport.send_notification(self, message)
        end

        def subscribe
          Isomorfeus::Transport.subscribe(self)
        end

        def unsubscribe
          Isomorfeus::Transport.unsubscribe(self)
        end
      end
    end
  end
end