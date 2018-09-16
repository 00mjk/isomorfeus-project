module IsmoOperation
  class Base
    def self.inherited(base)
      base.include(::IsmoOperation::Mixin)
    end
  end
end