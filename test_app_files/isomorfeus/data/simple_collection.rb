class SimpleCollection < LucidData::Collection::Base
  execute_load do
    1..5.each do |k|
      SimpleNode.load(key: k)
    end
  end

  on_load do
    # nothing
  end
end
