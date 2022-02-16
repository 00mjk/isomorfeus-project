## Upgrading

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
