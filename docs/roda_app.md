## The Server App

By default a most simple Roda app get installed as Server for Isomorfeus Component based pages and other things.
To learn more about Roda and how you can further extend its capabilities see the [Roda Documentation](http://roda.jeremyevans.net/documentation.html)

It has 3 major parts and task:
1. require all ruby gems and set up environment.
2. Extend the default Roda App with isomorfeus functionality
3. the actual Roda app, route requests, assemble pages.

Routing for pages in Isomorfeus is completely done in the Preact Wouter, no need to modify the Roda App.
The catch all route at 4. (see below) takes care of it.

Of course, you may add routes for other things. If you do, you must restart the server in development for routes to take effect.

It looks like this:
```ruby
# 1. require all ruby gems and set up environment
require_relative 'app_loader'
require_relative 'owl_init'
require_relative 'arango_config'
require_relative 'iodine_config'

class TestAppApp < Roda
  # 2. Extend the default Roda App with isomorfeus functionality
  extend Isomorfeus::Transport::Middlewares
  include Isomorfeus::PreactViewHelper

  use_isomorfeus_middlewares
  plugin :public, root: 'public', gzip: true

  def page_content(env, location)
    locale = env.http_accept_language.preferred_language_from(Isomorfeus.available_locales)
    locale = env.http_accept_language.compatible_language_from(Isomorfeus.available_locales) unless locale
    locale = Isomorfeus.locale unless locale
    rendered_tree = mount_component('TestAppApp', location_host: env['HTTP_HOST'], location: location, locale: locale)
    <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Welcome to TestAppApp</title>
          <meta charset="utf-8"/>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style id="jss-server-side" type="text/css">#{ssr_styles}</style>
          #{script_tag 'application.js'}
        </head>
        <body>
          #{rendered_tree}
        </body>
      </html>
    HTML
  end

  # 3. the actual Roda app, route requests, assemble pages.
  route do |r|
             
    r.root do
      page_content(env, '/')
    end

    r.public

    r.get 'favicon.ico' do
      r.public
    end

    r.get 'robots.txt' do
      r.public
    end

    # 4. catch all other routes to go to the Isomorfeus react router 
    r.get do
      content = page_content(env, env['PATH_INFO'])
      response.status = ssr_response_status
      content
    end
  end
end
```
