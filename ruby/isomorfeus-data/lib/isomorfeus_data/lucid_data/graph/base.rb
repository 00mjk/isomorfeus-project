module LucidData
  module Graph
    class Base
      include LucidData::Graph::Mixin

      if RUBY_ENGINE != 'opal'
        def self.inherited(base)
          Isomorfeus.add_valid_data_class(base)
        end
      end
    end
  end
end
