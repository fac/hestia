class FakeCookieJar
  attr_reader :request, :key_generator, :signed_cookie_salt, :cookies_digest

  def initialize(secret)
    @secret = secret
    @request = self
    @signed_cookie_salt = nil
    @cookies_digest = nil
    @key_generator = ActiveSupport::LegacyKeyGenerator.new(@secret)
  end
end
