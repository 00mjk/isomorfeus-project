require_relative 'app_loader'
require_relative 'owl_init'
require_relative 'iodine_config'

class TestAppApp < Roda
  extend Isomorfeus::Transport::Middlewares
  include OpalWebpackLoader::ViewHelper
  include Isomorfeus::ReactViewHelper

  use_isomorfeus_middlewares
  plugin :public, root: 'public'

  def page_content(env)
    location = env['PATH_INFO']
    location_host = env['HTTP_HOST']
    location_scheme = env['rack.url_scheme']
    <<~HTML
      <html>
        <head>
          <title>Welcome to TestAppApp</title>
          #{owl_script_tag 'application.js'}
        </head>
        <body>
          #{mount_component('TestAppApp', location: location, location_host: location_host, location_scheme: location_scheme)}
          <div id="test_anchor"></div>
        </body>
      </html>
    HTML
  end

  route do |r|
    r.root do
      page_content('/')
    end

    r.public

    r.get 'favicon.ico' do
      r.public
    end

    r.get 'ssr' do
      <<~HTML
      <html>
        <head>
          <title>Welcome to TestAppApp</title>
        </head>
        <body>
          #{mount_component('TestAppApp', location: env['PATH_INFO'], location_host: env['HTTP_HOST'],
                            location_scheme: env['rack.url_scheme'])}
          <div id="test_anchor"></div>
        </body>
      </html>
      HTML
    end

    r.get do
      page_content(env)
    end
  end
end
