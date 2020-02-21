## Authentication

For authentication in isomorfeus there is a class `Anonymous`, so whenever no user is logged in, the anonymous user is passed on to operations
or data loads or other places. In my opinion it is more true than no user (nil), because in fact there probably is a user, just the user is unknown.
The Anonymous user has a default policy that allows everything, the user will respond to .authorized?(whatever) always with true by default.
Of  course, the developer can add a Policy easily, to deny certain operations or data loads, or whatever or deny everything:
```ruby
class AnonymousPolicy < LucidPolicy::Base
 deny all
end
```
For more information about policy see [the policy docs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-policy/README.md).

A class representing a user should be a LucidNode and include LucidAuthentication::Mixin (for login) and LucidAuthorization::Mixin (for policy)
```ruby
class User < LucidGenericDocument::Base
  include LucidAuthentication::Mixin
  include LucidAuthorization::Mixin

  execute_login do |user:, pass:|
    if RUBY_ENGINE != 'opal' # guard to prevent inclusion of code client side to keep asset size low
      # should return either a User instance or a Promise which resolves to a User instance
      # The returned instance must be instance of a LucidData class  
    end 
  end
end
```
With that its possible to do on the client (or server):
```ruby
User.promise_login(user: user_identifier, pass: user_password_or_token)
# or
User.promise_login(user: user_identifier, pass: user_password_or_token) do |user|
  # return a path for redirection
  # user is the instance of the logged in user, but current_user has not been set 
  # current_user will be set and globally available after the redirect.
  # If this block is used it must return a path starting with '/', it will be the path the system redirects the
  # user to, the path the user will land on after successful login 
  '/dashboard'
end
```

> *ATTENTION:* The standard isomorfeus authentication scheme accepts a *block* -> `promise_login() do` and *NOT* a `promise_login().then do`. 
Other authentication though schemes may accept a `promise_login().then` (see the facebook scheme example below).

or later on:
```ruby
user.promise_logout
```
promise_logout will reinitialize the client side store.

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

### promise_login in Detail

`promise_login` accepts 3 keyword args:
- user: the user name or email or whatever is used for login
- pass: the password or token used for login
- scheme: the authentication scheme to use. With this other authentication schemes can be implmented and accessed, like :facebook. The default
scheme is :isomorfeus, the standard isomorfeus login procedure as described below.

prommise_login accepts a block, example:
```ruby
MyUser.promise_login(user: 'name', pass: 'pass') do |user|
  '/dashboard'
end
```
After a *successful login*, the block receives the user and must return a path as string starting with a '/' where the user is redirected to after
the browser received the session cookie. If no `do` block is provided, the user is redirected to the current page again.
Once the target page is loaded, the `current_user` accessor available in many Isomorfeus classes will supply the logged in user.
Alternatively the `Isomorfeus.current_user` accessor can be used.

As long as no user is logged in or after log out, the `current_user` accessor will return a instance of `Anonymous`

A .fail block can be used to handle *login failure*, example:
```ruby
MyUser.promise_login(user: 'name', pass: 'pass') do |user|
  '/dashboard'
end.fail do |error|
  # handle error, eg. change component state or so
end
```

The general :isomorfeus scheme login procedure is as follows:
- client, over a (secure in production) socket authenticates *successfully* using promise_login
- the server creates cookie eater and session cookie and session
- server returns over (secure) socket the user (for inspection in the `do` block of promise_login) and the cookie eater cookie 
- client engages cookie eater, that means:
    - page load with cookie eater cookie
    - that sets session cookie securely HttpOnly (and Secure in production)
    - redirects to landing page (as returned by the `do` block, landing page MUST be a path starting with '/', no host, port etc. allowed.
- client loads landing page
- SSR kicks in, gets session id from session cookie as transmitted by page load request
- SSR logs in using session id (it has to, as it is just "another browser" in a way)
- SSR renders page with user specific data
- page is returned to client, with all data, including current_user

Login with the :isomorfeus scheme may create 3 situations:
1. *Login successful*: promise_login -> do engage cookie eater -> redirect -> current_user is the logged in user
2. *Login failed*: promise_login -> .fail block
3. *Login successful and cookie eater cookie stolen*: promise_login -> do engage cookie eater -> destroy existing session -> redirect -> current_user is Anonymous
(This is theoretical. Stealing the cookie eater cookie is virtually impossible. It is consumed (eaten) immediately after creation and as cookies
in real life, can only be eaten once.)

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
