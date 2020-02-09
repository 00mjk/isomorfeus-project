class Anonymous
  include LucidAuthorization::Mixin

  def anonymous?
    true
  end

  def key
    'anonymous'
  end
end
