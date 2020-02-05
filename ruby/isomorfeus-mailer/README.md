# isomorfeus-mailer

Build mails with components and send them.

### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com) 

### Configuration

TODO

### Usage

Within a isomorfeus project componetns for building emails are the app/mail_components directory.
When using LucidComponent or LucidMaterial::Component the main component passed to the mail must be either a LucidApp or LucidMaterial::App component.

One class is provided to actually build and send the mail: LucidMail.

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


