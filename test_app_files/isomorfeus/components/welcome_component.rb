class WelcomeComponent < React::FunctionComponent::Base
  create_function do
    DIV "Welcome!"
    NavigationLinks()
  end
end
