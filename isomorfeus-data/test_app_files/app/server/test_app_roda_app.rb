Isomorfeus.load_configuration(File.expand_path(File.join(__dir__, '..', '..', 'config')))

class TestAppRodaApp < Roda
  extend Isomorfeus::Transport::Middlewares
  include Isomorfeus::PreactViewHelper
  use_isomorfeus_middlewares
  plugin :public, root: 'public'
  plugin :render, views: File.join(__dir__, '..', 'layouts'), cache: Isomorfeus.production?

  def locale
    env.http_accept_language.preferred_language_from(Isomorfeus.available_locales) ||
      env.http_accept_language.compatible_language_from(Isomorfeus.available_locales) ||
      Isomorfeus.locale
  end

  def page_content(env, location)
    req = Rack::Request.new(env)
    skip_ssr = req.params.key?("skip_ssr") ? true : false
    mount_component('TestAppApp', { location_host: env['HTTP_HOST'], location: location, locale: locale }, 'ssr.js', skip_ssr: skip_ssr)
  end

  route do |r|
    r.root do
      content = page_content(env, '/')
      response.status = ssr_response_status
      render('web', locals: { content: content, title: 'TestAppApp', script_tag: script_tag('web.js') })
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
        render('web', locals: { content: content, component_class: component_class })
      end
    end

    r.get 'ssr' do
      content = page_content(env, env['PATH_INFO'])
      response.status = ssr_response_status
      render('ssr', locals: { content: content, title: 'TestAppApp' })
    end

    r.get do
      content = page_content(env, env['PATH_INFO'])
      response.status = ssr_response_status
      render('web', locals: { content: content, title: 'TestAppApp', script_tag: script_tag('web.js') })
    end
  end
end
