module LucidAranog
  module Document
    module Mixin
      def self.included(base)
        base.include(LucidArango::Node::Mixin)
      end
    end
  end
end
