module LucidHandler
  module Mixin
    def self.included(base)
      Isomorfeus.add_valid_handler_class(base) unless base == LucidHandler::Base
    end
  end
end
