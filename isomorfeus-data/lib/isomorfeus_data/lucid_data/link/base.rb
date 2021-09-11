module LucidData
  module Link
    class Base
      def self.inherited(base)
        base.include LucidData::Edge::Mixin
        if RUBY_ENGINE != 'opal'
          Isomorfeus.add_valid_data_class(base)
        end
      end
    end
  end
end
