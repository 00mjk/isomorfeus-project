class SimpleEdgeCollection < LucidData::Collection::Base
  execute_load do |key:|
    (1..5).map do |k|
      SimpleEdge.load(key: k)
    end
  end

  on_load do
    # nothing
  end
end
