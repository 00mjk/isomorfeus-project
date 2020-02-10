## Authentication

For authentication in isomorfeus there is a class `Anonymous`, so whenever no user is logged in, the anonymous user is passed on to operations
or data loads. In my opinion it is more true than no user (nil), because in fact there probably is a user, just the user is unknown.
The Anonymous user has a default policy that allows everything, the user will respond to .authorized?(whatever) always with true by default.
Of  course, the developer can add a Policy easily, to deny certain operations or data loads, or whatever or deny everything:
```ruby
class AnonymousPolicy < LucidPolicy::Base
 deny all
end
```
For more information about policy see [the policy docs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-policy/README.md).

A class representing a user should be a LucidNode and include LucidAuthentication::Mixin:
```ruby
class User < LucidGenericDocument::Base
  include LucidAuthentication::Mixin

  execute_login do |user:, pass:|
    # should return either a User instance or a Promise which resolves to a User instance
    # The returned instance must be instance of a LucidData class  
  end
end
```
With that its possible to do on the client (or server):
```ruby
User.promise_login(user: user_identifier, pass: user_password_or_token).then do |user|
   # do something with user
end
```
or later on:
```ruby
user.promise_logout
```
The authentication in isomorfeus is prepared for external or alternate authentication schemes, example:
```ruby
User.promise_login(user: user_identifier, pass: token, :facebook).then do |user|
   # do something with user
end
```
will call:
```ruby
User.promise_authentication_with_facebook(user: user_identifier, pass: token)
```
which would have to be implemented.

### Convenience methods

The LucidAuthentication::Mixin provides a few convenience methods:

- anonymous? - to make checking for anonymous convenient, all classes that include the mixin and the Anonymous class have this method. So its easy to do:
```ruby
  unless current_user.anonymous?
    # do something
  end
```

On the server there are two methods to assist with passwords:
- encrypt_password(password, password_confirmation) - returns a string, the encrypted password, that can be stored in a db
- passwords_match?(encrypted_password, given_password) - takes the encrypted password returned by former method and a given password and compares them

## Current User

Across the system most classes provide a `current_user` convenience method, which returns the current user. If no user is logged in, a anonymous user
of class `Anonymous` is returned.

Where `current_user` is unavailable, `Isomorfeus.current_user` can be used.
