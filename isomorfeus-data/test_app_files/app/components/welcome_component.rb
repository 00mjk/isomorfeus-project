class WelcomeComponent < Preact::FunctionComponent::Base
  render do
    DIV "Welcome!"
    NavigationLinks()
  end
end
