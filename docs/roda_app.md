## The Server App

By default a most simple Roda app gets installed as Server for Isomorfeus Component based pages and other things.
To learn more about Roda and how you can further extend its capabilities see the [Roda Documentation](http://roda.jeremyevans.net/documentation.html)

It has 2 major parts and task:
1. Extend the default Roda App with isomorfeus functionality
2. the actual Roda app, route requests, assemble pages.

Routing for pages in Isomorfeus is completely done in the Preact Wouter, no need to modify the Roda App.
The catch all route at 3. (see below) takes care of it.

Of course, you may add routes for other things. If you do, you may need to restart the server in development for routes to take effect.

The environment can be changed by setting the environment variable `RACK_ENV`.
Three environment types are supported:
- 'production' - for deployment, configured automatically for performance and safety
- 'development - for development, configured automatically for hot reloading and development comfort
- 'test - used when running specs

It looks like this:
```ruby
Isomorfeus.load_configuration(File.expand_path(File.join(__dir__, '..', '..', 'config')))

class IsomorfeusWebsiteRodaApp < Roda
  # 1. Extend the default Roda App with isomorfeus functionality
  extend Isomorfeus::Transport::Middlewares
  include Isomorfeus::PreactViewHelper

  use_isomorfeus_middlewares

  plugin :public, root: 'public', gzip: true

  @@templates = {}
  @@templates_path = File.expand_path(File.join(__dir__, '..', 'layouts'))

  def locale
    env.http_accept_language.preferred_language_from(Isomorfeus.available_locales) ||
        env.http_accept_language.compatible_language_from(Isomorfeus.available_locales) ||
        Isomorfeus.locale
  end

  def page_content(env, location)
    if Isomorfeus.development?
      req = Rack::Request.new(env)
      skip_ssr = req.params.key?("skip_ssr") ? true : false
    else
      skip_ssr = false
    end
    mount_component('IsomorfeusWebsiteApp',{ location_host: env['HTTP_HOST'], location: location, locale: locale }, 'ssr.js', skip_ssr: skip_ssr)
  end

  def render(template_name, locals: {})
    @@templates.delete(template_name) if Isomorfeus.development? # cause reloading of template in development environment
    unless @@templates.key?(template_name)
      @@templates[template_name] = Iodine::Mustache.new(File.join(@@templates_path, "#{template_name}.mustache"))
    end
    @@templates[template_name].render(locals)
  end

  # 2. the actual Roda app, route requests, assemble pages.
  route do |r|
    r.root do
      content = page_content(env, '/')
      response.status = ssr_response_status
      render('web', locals: { content: content, script_tag: script_tag('web.js'), ssr_styles: ssr_styles, title: 'Welcome to IsomorfeusWebsiteApp' })
    end

    r.public

    r.get 'favicon.ico' do
      r.public
    end

    r.get 'robots.txt' do
      r.public
    end

    unless Isomorfeus.production?
      r.on 'mail_preview', String do |component_name|
        component_class = component_name.camelize
        props = { location_host: env['HTTP_HOST'], location: '/mail_preview', locale: locale }.merge(r.params)
        content = mount_component(component_class, props, 'mail_components.js')
        response.status = ssr_response_status
        render('mail_preview', locals: { content: content, component_class: component_class, ssr_styles: ssr_styles })
      end
    end

    # 3. catch all other routes to go to the Isomorfeus Preact Wouter router
    r.get do
      content = page_content(env, env['PATH_INFO'])
      response.status = ssr_response_status
      render('web', locals: { content: content, script_tag: script_tag('web.js'), ssr_styles: ssr_styles, title: 'Welcome to IsomorfeusWebsiteApp' })
    end
  end
end
```
