class AllTypesComponent < LucidMaterial::Component::Base
  include LucidTranslation::Mixin

  render do
    DIV 'Rendered!'
    DIV _('simple')
    DIV 'abcdef'
    NavigationLinks()
  end
end