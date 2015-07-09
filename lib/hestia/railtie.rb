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
        Hestia::SignedCookieJarExtension::ActionPack4
      else
        raise "Unsupported version of action_pack: #{ActionPack::VERSION::STRING.inspect}"
      end

      ActionDispatch::Cookies::SignedCookieJar.prepend(extension)
    end
  end
end
