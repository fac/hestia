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
      when 4
        Hestia.check_secret_key_base
        Hestia::SignedCookieJarExtension::ActionPack4
      when 5
        Hestia.check_secret_key_base
        Hestia::SignedCookieJarExtension::ActionPack5
      end

      ActionDispatch::Cookies::SignedCookieJar.prepend(extension)
    end
  end
end
