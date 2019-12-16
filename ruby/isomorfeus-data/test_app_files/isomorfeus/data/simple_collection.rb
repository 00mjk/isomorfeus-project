class SimpleCollection < LucidData::Collection::Base
  execute_load do |key:|
    nodes = (1..5).map do |k|
      SimpleNode.load(key: k)
    end
    { key: key, nodes: nodes }
  end

  on_load do
    # nothing
  end
end
