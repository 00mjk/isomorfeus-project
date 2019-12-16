class AllTypesComponent < LucidComponent::Base
  render do
    DIV 'Rendered!'
    NavigationLinks()
  end
end