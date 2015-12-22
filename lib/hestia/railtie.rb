require "hestia"

module Hestia
  class Railtie < ::Rails::Railtie
    # Hooks into ActionDispatch::Session::SignedCookieJar to allow rotating secret tokens in signed cookies.
    #
    # See README.md for how to configure this in your application.
    #
    initializer "hestia.signed_cookie_jar_extension", before: :load_config_initializers do
      extension = case ActionPack::VERSION::MAJOR
      when 3
        Hestia::SignedCookieJarExtension::ActionPack3
      else
        if Rails.application.config.respond_to?(:secret_key_base) && Rails.application.config.secret_key_base
          fail "Having `config.secret_token' and `config.secret_key_base' defined is not allowed in Hestia. Please refer to Hestia's Readme for more information."
        end

        Hestia::SignedCookieJarExtension::ActionPack4
      end

      ActionDispatch::Cookies::SignedCookieJar.prepend(extension)
    end
  end
end
