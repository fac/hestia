# Hestia

Add support for deprecating/rotating the signed cookie secret token in rails. Out of the box if you change `config.secret_token` in rails, as soon as you deploy the change all your existing signed cookies are rendered invalid with lovely side effects such as all of your users being logged out. Thing is, it would be nice to rotate the secret token occasionally, without that side effect.

Enter hestia! You can now change your `config.secret_token`, and move the old value to `config.deprecated_secret_token` to allow existing cookies to be read in as valid cookies, but all cookies being sent out of the app are signed using the new secret token value. After a while all your users that have been active since the change will have cookies signed by the new token, and you can remove the old token from `config.deprecated_secret_token`. Hey presto, you just changed your `config.secret_token` without logging anyone out or losing any existing cookies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "hestia", :require => "hestia/railtie"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hestia

And then require the railtie during your application boot process somewhere:

```ruby
require "hestia/railtie"
```

## Usage

### Rails 3.2

You should already have `Rails.application.config.secret_token` set to a value (usually in `config/initializers/secret_token.rb`). To rotate to a new value, you need to:

1. Install hestia into your app as instructed in the "Installation" section.

2. Update your config file so the old secret token is considered deprecated and you've set a new secret token value *(Use `rake secret` to generate one)*

        Rails.application.config.secret_token = "new token (from rake secret output)"
        Rails.application.config.deprecated_secret_token = "old secret token value (previously on line above)"

3. Deploy. Your existing cookies will Just Work™, but any outgoing cookies are signed with new token.

4. A while later (couple of weeks?), remove the `config.deprecated_secret_token` line. (Any existing cookies that haven't been sent to the webserver are now rendered invalid.)

5. Be happy you've changed your cookie secret without logging anyone out.

*You can also set `config.deprecated_secret_token` to an array of strings to allow incoming cookies to be valid when signed with any of the secrets.*

### Rails 4

We support Rails 4.1. Rails 4.0 & 4.2 are unsupported at this time. (Pull requests welcome!)

Following the instructions for Rails 3.2 should work, but make sure you haven't set `config.secret_key_base` to a value otherwise Rails will take over and upgrade your cookies from signed to encrypted ones.

### Outside rails

If you're using `ActiveSupport::MessageVerifier` anywhere and you'd like to be able to rotate the secrets, you could use `Hestia::MessageMultiVerifier` instead to gain the ability to rotate secrets. See the documentation in the class for more information about how to use it.

## Contributing

1. Fork it ( https://github.com/fac/hestia/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
