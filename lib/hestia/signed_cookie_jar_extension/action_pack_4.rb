module Hestia
  module SignedCookieJarExtension
    module ActionPack4
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
        super

        # Find the deprecated secrets, if there are any
        deprecated_secrets = if Rails.application.config.respond_to?(:deprecated_secret_token)
          # This could be a single string!
          Array(Rails.application.config.deprecated_secret_token)
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
