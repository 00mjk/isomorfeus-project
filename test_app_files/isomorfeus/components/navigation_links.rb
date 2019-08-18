class NavigationLinks < React::FunctionComponent::Base
  create_function do
    P do
      Link(to: '/') { 'Hello World!' }
      SPAN " | "
      Link(to: '/welcome') { 'Welcome!' }
      SPAN " | "
      Link(to: '/ssr') { 'SSR!' }
      SPAN " | "
      Link(to: '/snc') { 'SSR and|or CSR!' }
    end
  end
end