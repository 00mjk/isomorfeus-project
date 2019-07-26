module LucidHandler
  module Mixin
    def self.included(base)
      Isomorfeus.add_valid_handler_class(base) unless base == LucidHandler::Base

      base.instance_exec do
        def on_request(&block)
          define_method :process_request do |*args|
            block.call(*args)
          end
        end
      end
    end
  end
end
