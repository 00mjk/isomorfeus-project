class SimpleHash < LucidHash::Base
  load_query do
    { simple_key: 'simple_value' }
  end
end
