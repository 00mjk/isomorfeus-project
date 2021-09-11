class EmailComponent < LucidApp::Base
  prop :name

  render do
    DIV "Welcome #{props.name}!"
  end
end
