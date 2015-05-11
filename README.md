# understudy
Shadow your ruby code with a newer version. Log the difference between the two versions. Release with confidence.


## Example

Let's say you have a TextCleaner. It can transliterate Unicode to ASCII. For example, "ß" becomes "ss". Then you write a faster version. It uses a C library to transliterate, instead of a Ruby lookup table.

Your test suite still passes, when you swap in FasterTextCleaner, but how would test it against *every* string your app encounters?

``` ruby
# ./config/initializers/text_cleaning.rb

Understudy.new(TextCleaner, FasterTextCleaner, :transliterate)

```

TextCleaner is now monkey-patched to call both TextCleaner.transliterate and FasterTextCleaner.transliterate with each input. It will return the result from TextCleaner.transliterate and log whether FasterTextCleaner returned the same result.

``` log
UNDERSTUDY FAIL: FasterTextCleaner#transliterate returned "Schloß Wolfsgarten". It should have returned "Schloss Wolfsgarten". args were: ["Schloß Wolfsgarten"]
```

If your original method raises, your new method must also raise, with a matching exception message.

## Class methods

Understudy works with class methods:

``` ruby
# ./config/initializers/text_cleaning.rb

Understudy.new(TextCleaner, FasterTextCleaner, {:self=>:transliterate})

```

## Shadow multiple methods

You can pass an array of methods. Each method will be shadowed.

``` ruby
# ./config/initializers/text_cleaning.rb

Understudy.new(TextCleaner, FasterTextCleaner, [:transliterate, :strip_ms_word, :csv_safe])

```

## Custom comparison

Want to allow for some differences? You can customise what Understudy diffs by passing a block. The block should return an array of two objects for Understudy to compare.

``` ruby
# ./config/initializers/text_cleaning.rb

Understudy.new(TextCleaner, FasterTextCleaner, :transliterate]) do |old_result, fast_result|
  # TextCleaner.transliterate returns a string
  # but FasterTextCleaner returns a string and the number of characters cleaned

  fast_result_string, _ = fast_result

  [old_result, fast_result_string]
end

```
