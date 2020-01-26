module LucidHandler
  module Mixin
    def self.included(base)
      Isomorfeus.add_valid_handler_class(base) unless base == LucidHandler::Base

      base.instance_exec do
        def on_request(&block)
          define_method :process_request do |*args|
            instance_exec(*args, &block)
          end
        end
      end
    end

    def resolving?
      false
    end

    def current_user
      Isomorfeus.current_user
    end

    def pub_sub_client
      Isomorfeus.pub_sub_client
    end
  end
end
