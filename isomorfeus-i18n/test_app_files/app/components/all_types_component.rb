class AllTypesComponent < LucidComponent::Base
  render do
    DIV 'Rendered!'
    DIV _('simple')
    DIV 'abcdef'
    NavigationLinks()
  end
end