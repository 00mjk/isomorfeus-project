module LucidData
  module LinkCollection
    module Mixin
      def self.included(base)
        base.include(LucidData::EdgeCollection::Mixin)
      end
    end
  end
end
