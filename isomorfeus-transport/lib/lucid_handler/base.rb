module LucidHandler
  class Base
    def self.inherited(base)
      base.include LucidHandler::Mixin
      Isomorfeus.add_valid_handler_class(base)
    end
  end
end
