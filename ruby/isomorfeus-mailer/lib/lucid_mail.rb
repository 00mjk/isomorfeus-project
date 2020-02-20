class LucidMail
  include Isomorfeus::ReactViewHelper
  extend LucidPropDeclaration::Mixin

  prop :from, class: String, required: true
  prop :reply_to, class: String, required: false
  prop :to, class: String, required: true
  prop :subject, class: String, required: true
  prop :component, class: String, required: true
  prop :props

  attr_reader :mail
  attr_reader :props
  attr_reader :rendered_component

  def initialize(**props)
    self.class.validate_props(props)
    @props = LucidProps.new(props)
    @mail = nil
    @rendered_component = nil
  end

  def render_component
    rendered_tree = mount_static_component(props.component, props.props, 'mail_components.js')
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
