## Upgrading

### from 2.1 to 2.2

to benefit from improved behavior in development update 'config.ru' to the following pattern,
changing the 2 occurances of YourAppClass to the class of your app:
```ruby
require_relative 'app_loader'

if !Isomorfeus.development?
  Isomorfeus.zeitwerk.setup
  Isomorfeus.zeitwerk.eager_load

  run YourAppClass.freeze.app # <- change here
else
  Isomorfeus.zeitwerk.enable_reloading
  Isomorfeus.zeitwerk.setup
  Isomorfeus.zeitwerk.eager_load

  run ->(env) do
    if Isomorfeus.server_requires_reload?
      write_lock = Isomorfeus.zeitwerk_lock.try_write_lock
      if write_lock
        Isomorfeus.server_reloaded!
        Isomorfeus.zeitwerk.reload
        Isomorfeus.zeitwerk_lock.release_write_lock
      end
    end
    Isomorfeus.zeitwerk_lock.with_read_lock do
      YourAppClass.call env # <- change here
    end
  end
end
```

### from 2.0 to 2.1

#### Breaking changes:
- the default storage dirctory has been renamed from your_project_root/data to your_project_root/storage
- the layout within the storage directory changed for LucidObject, now there is a directory per LucidObject class
- isomorfeus-i18n: LucidTranslation has been renamed to LucidI18n
```ruby
# before with isomorfeus 2.0:
class MyClass
  include LucidTranslation::Mixin

# with isomorfeus 2.1 change to:
class MyClass
  include LucidI18n::Mixin
```
- isomorfeus-data: the policy method for LucidQuery has been renamed from :query to :execute, example:
```ruby
class MyPolicy < LucidPolicy::Base
  # before with isomorfeus 2.0:
  allow MyQuery, :query

  # with isomorfeus 2.1 change to:
  allow MyQuery, :execute
end
```
- instance store is gone, instead just use state for Components

#### Other Changes
- the LucidI18n::Mixin is automatically included in LucidApp, LucidComponent and LucidFunc components
- the LucidI18n::Mixin is automatically included in LucidDocument, Lucidfile, LucidObject and LucidQuery data classes
- the `current_locale` helper is available everywhere, where the LucidI18n::Mixin is included, everywhere else `Isomorfeus.current_locale` is available
- the current locale is automatically negotiated and set by a rack handler
