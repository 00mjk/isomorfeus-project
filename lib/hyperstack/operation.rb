module Isomorfeus
  class Operation
    def self.inherited(child)
      child.include(Isomorfeus::Operation::Mixin)
    end
  end
end