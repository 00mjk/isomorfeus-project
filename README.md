# isomorfeus-i18n

Locale files go in my_app/isomorfeus/locales.
Supported formats: .mo, .po, .yml

Using fast_gettext internally.

## Usage

In any class:
```
  include LucidTranslation::Mixin
```

after which the _ gettext methods are available for translation.
See https://github.com/grosser/fast_gettext and https://rubydoc.info/gems/gettext/
