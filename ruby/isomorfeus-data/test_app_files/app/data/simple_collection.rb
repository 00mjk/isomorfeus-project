class SimpleCollection < LucidData::Collection::Base
  execute_create do
    self
  end

  execute_load do |key:|
    nodes = (1..5).map do |k|
      SimpleNode.load(key: k)
    end
    new(key: key, nodes: nodes)
  end

  execute_save do
    self
  end

  execute_destroy do |key:|
    true
  end
end
