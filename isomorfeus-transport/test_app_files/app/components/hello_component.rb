class HelloComponent < LucidComponent::Base
  render do
    DIV 'Rendered!'
    DIV "#{class_store.a_value}"
    DIV "#{store.a_value}"
    DIV "#{app_store.a_value}"
    NavigationLinks()
  end
end
