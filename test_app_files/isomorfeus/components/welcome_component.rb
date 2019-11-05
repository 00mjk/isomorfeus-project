class WelcomeComponent < React::FunctionComponent::Base
  render do
    DIV "Welcome!"
    NavigationLinks()
  end
end
