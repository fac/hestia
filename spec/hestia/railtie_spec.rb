require_relative "../spec_helper"
require_relative "../support/fake_rails"

require "hestia/railtie"

module Hestia
  describe Railtie do
    before do
      @name, @arguments, @block = Rails::Railtie.initializers.first
    end

    describe "initializer" do
      it "adds an initializer" do
        Rails::Railtie.initializers.wont_be_empty
      end

      it "has a name" do
        @name.must_equal "hestia.signed_cookie_jar_extension"
      end

      it "is run before config initializers are loaded" do
        @arguments[:before].must_equal :load_config_initializers
      end

      it "has a block to do some work" do
        # The block itself is tested in the SignedCookieJarExtension spec
        refute_nil @block
      end
    end
  end
end
