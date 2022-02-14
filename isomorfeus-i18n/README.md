# isomorfeus-i18n

Internationalization for Isomorfeus.

### Community and Support
At the [Isomorfeus Framework Project](https://isomorfeus.com)

### Usage
Locale files go in my_app/isomorfeus/locales.
Supported formats: .mo, .po, .yml

Using fast_gettext internally.

## Translation

In any class:
```
  include LucidI18n::Mixin
```
after which the _ gettext methods are available for translation.
See the [fast_gettext documentation](https://github.com/grosser/fast_gettext) or the
[gettext documentation](https://rubydoc.info/gems/gettext/).

Also available is the `current_locale` helper, which provides the current locale as string, as it has been negotiated between browser and server.

## Localization

In any class:
```
  include LucidI18n::Mixin
```
after which the l method is available, which currently can localize Times, Dates and numbers.
See the [R18n core documentation](https://github.com/r18n/r18n-core)

Only the :full and :standard options are supported for the l method in all environments.

However, output may slightly differ between server and browser and also between browsers, depending on actual browser locale and implementation.
For most consistent and best results its best to format dates and numbers for display only within components in server side rendering or in the browser.

Within components, the l method allows for additional options for Date and Time objects:
```ruby
# signature
l(object, format = :standard, options = {})
```
Here format can be:
- :standard or :full, which try to be consistent with r18n options
and in addition:
- :custom, which passes the options hash along for formatting to the browser or node functions.
The following options are available for date/time formating:
- locale: locale string like 'de'
- time_zone or timeZone: timezone string like 'CET'
- time_zone_name or timeZoneName: "long" "short"
- date_style or dateStyle: "full" "long" "medium" "short"
- time_style or timeStyle: "full" "long" "medium" "short"
- format_matcher or formatMatcher: "best-fit"(default) "basic"
- locale_matcher or localeMatcher: "best-fit"(default) "lookup"
- hour12: false true
- hour_cycle hourCycle: "h11" "h12" "h23" "h24"
- hour:	   "2-digit" "numeric"
- minute:	 "2-digit" "numeric"
- second:	 "2-digit" "numeric"
- day	     "2-digit" "numeric"
- month:   "2-digit" "numeric" "long" "short" "narrow"
- weekday:                     "long" "short" "narrow"
- year:	   "2-digit" "numeric"
For formatting numbers the options are available:
- currency: any currency code (like "EUR", "USD", "INR", etc.)
- currency_display or currencyDisplay: "symbol"(default) "code" "name"
- locale_matcher or localeMatcher: "best-fit"(default) "lookup"
- maximum_fraction_digits or maximumFractionDigits: A number from 0 to 20 (default is 3)
- maximum_significant_digits or maximumSignificantDigits: A number from 1 to 21 (default is 21)
- minimum_fraction_digits or minimumFractionDigits: A number from 0 to 20 (default is 3)
- minimum_integer_digits or minimumIntegerDigits:	A number from 1 to 21 (default is 1)
- minimum_significant_digits or minimumSignificantDigits:	A number from 1 to 21 (default is 21)
- style: "decimal"(default) "currency" "percent"
- use_grouping or useGrouping: true(default) false

example:
```ruby
l(Time.now, :custom, { hour12: true })
l(1.2345, :custom, { maximum_fraction_digits: 2 })
```
