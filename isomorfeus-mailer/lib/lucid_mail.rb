class LucidMail
  include Isomorfeus::PreactViewHelper
  extend LucidPropDeclaration::Mixin

  prop :from, class: String, required: true
  prop :reply_to, class: String, required: false, allow_nil: true
  prop :to, class: String, required: true
  prop :subject, class: String, required: true
  prop :component, class: String, required: true
  prop :asset, class: String, default: 'mail.js'
  prop :props

  attr_reader :mail
  attr_reader :props
  attr_reader :rendered_component

  def initialize(**props)
    @props = LucidProps.new(self.class.validated_props(props))
    @mail = nil
    @rendered_component = nil
    @loc_h = if self.class.const_defined?('::Isomorfeus::Puppetmaster')
      "#{::Isomorfeus::Puppetmaster.served_app.host}:#{::Isomorfeus::Puppetmaster.served_app.port}"
    elsif self.class.const_defined?('::Iodine')
      "#{::Iodine::DEFAULT_SETTINGS[:address]}:#{::Iodine::DEFAULT_SETTINGS[:port]}"
    else
      'localhost:3000'
    end
  end

  def render_component
    component_props = { location_host: @loc_h }.merge(props.props)
    rendered_tree = mount_component(props.component, component_props, props.asset, use_ssr: true)
    @rendered_component = <<~HTML
    <!DOCTYPE html>
    <html><head><style type="text/css">#{ssr_styles}</style></head><body>#{rendered_tree}</body></html>
    HTML
    self
  end

  def build
    render_component unless rendered_component
    html_body = rendered_component
    text_body = Html2Text.convert(rendered_component)
    @mail = Mail.new
    @mail.to(props.to)
    @mail.from(props.from)
    @mail.subject(props.subject)
    @mail.reply_to(props.reply_to) if props.key?(:reply_to)
    @mail.text_part do
      content_type 'text/plain; charset=UTF-8'
      body text_body
    end
    @mail.html_part do
      content_transfer_encoding 'binary'
      content_type 'text/html; charset=UTF-8'
      body html_body
    end
    self
  end

  def send
    build unless mail
    Isomorfeus.email_sender.send_email(mail)
  end
end
