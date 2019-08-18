class Anonymous < BasicObject
  # policy methods get added by Isomorfeus::Transport::AnonymousPolicy
  def id
    'anonymous'
  end
end