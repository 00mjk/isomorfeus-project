module LucidHandler
  class Base
    def self.inherited(base)
      Isomorfeus.add_valid_handler_class(base)
    end

    include LucidHandler::Mixin
  end
end
