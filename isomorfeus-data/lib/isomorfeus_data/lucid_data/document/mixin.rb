module LucidData
  module Document
    module Mixin
      def self.included(base)
        base.include(LucidData::Node::Mixin)
      end
    end
  end
end
