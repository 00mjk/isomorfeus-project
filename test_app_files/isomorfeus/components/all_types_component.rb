class AllTypesComponent < LucidComponent::Base
  include LucidTranslation::Mixin

  render do
    DIV 'Rendered!'
    DIV _('simple')
    DIV 'abcdef'
    NavigationLinks()
  end
end