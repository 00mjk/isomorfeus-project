class AllTypesComponent < LucidComponent::Base
  include LucidI18n::Mixin

  render do
    DIV 'Rendered!'
    DIV _('simple')
    DIV 'abcdef'
    NavigationLinks()
  end
end