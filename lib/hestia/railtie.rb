require "hestia"

module Hestia
  class Railtie < Rails::Railtie
    # Hooks into ActionDispatch::Session::SignedCookieJar to allow rotating secret tokens in signed cookies.
    #
    # See README.md for how to configure this in your application.
    #
    initializer "hestia.signed_cookie_jar_swizzling", before: :load_config_initializers do

      # Do the dirty on the SignedCookieJar to use our multi verifier
      class ActionDispatch::Cookies::SignedCookieJar
        # Move the initialize method aside, so we can redefine it and still call it
        # See ActionDispatch::Cookies::SignedCookieJar#initialize for implementation
        alias_method :__original_initalize__, :initialize

        # Public: overridden #initialize method
        #
        # In rails, `secrets' will be given the value of `Rails.application.config.secret_token'. That's the current secret token.
        # This also reads from `Rails.application.config.deprecated_secret_token` for deprecated token(s) to use. It can be undefined, a
        # string or an array of string.
        #
        # parent_jar [ActionDispatch::Cookies] the parent jar creating this signed cookie jar
        # secret [String] current secret token. Used to verify & sign cookies.
        #
        def initialize(parent_jar, secret)
          # Call the original implementation of initialize (`super' if you will.)
          __original_initalize__(parent_jar, secret)

          # Find the deprecated secrets, if there are any
          deprecated_secrets = if Rails.application.config.respond_to?(:deprecated_secret_tokens)
            # This could be a single string!
            Array(Rails.application.config.deprecated_secret_tokens)
          else
            []
          end

          # Ensure all the deprecated secret tokens are considered secure (__original_initalize__ checked the current secret for this)
          deprecated_secrets.each { |secret| ensure_secret_secure(secret) }

          # Finally, override @verifier with our own multi verifier containing all the secrets
          @verifier = Hestia::MessageMultiVerifier.new(current_secret: secret, deprecated_secrets: deprecated_secrets)
        end
      end

    end
  end
end
