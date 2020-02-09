# isomorfeus-mailer

Build mails with components and send them with [Mailhandler](https://github.com/wildbit/mailhandler#email-sending).

### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com) 

### Configuration

Configuration options can be set as hash passed to:
```ruby
Isomorfeus.email_sender_config = { type: :smtp }
```
All configuration options of Mailhandler can be passed in the hash. For Mailhandler option see
[Email sending](https://github.com/wildbit/mailhandler#email-sending) section of the Mailhandler docs.

### Usage

Within a isomorfeus project components for building emails are the app/mail_components directory.
When using LucidComponent or LucidMaterial::Component the main component passed to the mail must be either a LucidApp or LucidMaterial::App component.

One class is provided to actually build and send the mail: LucidMail. This class is only available on the server.

Example component:
```ruby
class EmailComponent < LucidApp::Base
  # the toplevel component must be a App component
  # then oder LucidComponent's can be used in the render block 

  prop :name

  render do
    DIV "Welcome #{props.name}!"
  end
end
```

Sending mail with the rendered component:
```ruby
mail = LucidMail.new(component: 'EmailComponent', 
                     props: { name: 'Siegfried' }, # are passed to the component
                     from: 'me@test.com',
                     to: 'you@test.com',
                     subject: 'Welcome')
mail.send
```

#### Triggering mail from a client
LucidMail is available only on the server. It can be wrapped in a operation to allow triggering the sending of mail from a client. Example:
```ruby
class MailOp < LucidQuickOp::Base
  op do
    LucidMail.new(component: 'EmailComponent', 
                  from: 'me@test.com',
                  to: current_user.email,
                  subject: 'Welcome')
  end
end
```
Make sure policy allows running the operation:
```ruby
class MyUserPolicy
  allow MailOp, :promise_run
end
```
Then on a client mail can be triggered:
```ruby
MailOp.promise_run
```
