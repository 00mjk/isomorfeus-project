class TestAppApp < LucidApp::Base
  render do
    Router(hook: Preact.location_hook(props.location)) do
      Switch do
        Route(path: '/', component: HelloComponent.JS[:preact_component])
        Route(path: '/ssr', component: AllTypesComponent.JS[:preact_component])
        Route(path: '/snc', component: AllTypesComponent.JS[:preact_component])
        Route(path: '/welcome', component: WelcomeComponent.JS[:preact_component])
      end
    end
  end
end