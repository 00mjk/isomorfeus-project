module LucidChannel
  module Mixin
    def self.included(base)
      base.instance_exec do
        def process_message(message)
          puts "#{self} received: #{message}"
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