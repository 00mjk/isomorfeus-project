class AllTypesComponent < LucidComponent::Base
  render do
    DIV 'Rendered!'
    DIV _('simple')
    DIV 'abcdef'
    DIV "localized numbers: #{l(1000)} #{l(1.2345)}"
    NavigationLinks()
  end
end