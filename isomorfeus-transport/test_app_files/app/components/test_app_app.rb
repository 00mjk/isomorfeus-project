class TestAppApp < LucidApp::Base
  render do
    Router(hook: Preact.location_hook(props.location)) do
      Switch do
        Route(path: '/', exact: true, component: HelloComponent.JS[:react_component])
        Route(path: '/snc', exact: true, component: HelloComponent.JS[:react_component])
        Route(path: '/ssr', exact: true, component: HelloComponent.JS[:react_component])
        Route(path: '/welcome', exact: true, component: WelcomeComponent.JS[:react_component])
      end
    end
  end
end