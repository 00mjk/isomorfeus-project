class FastGettext::Cache
  def reload_all!
    @store = {}
    reload!
  end
end
