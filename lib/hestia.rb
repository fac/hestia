module Hestia
  autoload :MessageMultiVerifier, "hestia/message_multi_verifier"
  autoload :SignedCookieJarExtension, "hestia/signed_cookie_jar_extension"
  autoload :VERSION, "hestia/version"

  def self.check_secret_key_base
    if Rails.application.config.respond_to?(:secret_key_base) && Rails.application.config.secret_key_base
      fail "Having `config.secret_token' and `config.secret_key_base' defined is not allowed in Hestia. Please refer to Hestia's Readme for more information."
    end
  end
end
