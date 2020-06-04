# Ransack UI

Provides HTML templates and JavaScript to build a fully functional
advanced search form using Ransack.

Please note: this project is still in *alpha* and the following instructions are not yet complete/fully working.

## Installation

Add this line to your application's Gemfile:

    gem 'ransack_ui'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ransack_ui

## Usage

Make your model ransackable (if you name associations, it will enable you to search them aswell).

```ruby
has_ransackable_associations %w(account tags)
ransack_can_autocomplete
```

In your controller, where you'd like to add search functionality, add the following before_filter hook. You can change the 'index' action if needed.

```ruby
before_filter :load_ransack_search, :only => :index
```

Insert the following helper call into your rails view code where you'd like the search form to appear.

```ruby
= ransack_ui_search
```

Now you can start playing with the results.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits / Acknowledgements

* Nathan Broadbent (ndbroadbent) - creator of ransack_ui code
* Ernie Miller (ernie) for creating ransack - https://github.com/ernie/ransack
* Steve Kenworthy (steveyken) - for tiny tweaks
