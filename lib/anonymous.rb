class Anonymous < BasicObject
  def authenticated?
    false
  end

  def id
    'anonymous'
  end
end