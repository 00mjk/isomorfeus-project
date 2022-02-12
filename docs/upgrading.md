## Upgrading

### from 2.0 to 2.1

Breaking changes:
- the default storage dirctory has been renamed from your_project_root/data to your_project_root/storage: `mv my_project_root/data my_project_root/storage`
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
