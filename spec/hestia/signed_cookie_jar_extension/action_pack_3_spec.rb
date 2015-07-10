require_relative "../../spec_helper"
require_relative "../../support/fake_rails"

# Call our railtie block to setup the initializers array
require "hestia/railtie"

module Hestia
  if ActionPack::VERSION::MAJOR == 3
    describe SignedCookieJarExtension::ActionPack3 do
      before do
        Rails.clean
        load_railtie
      end

      it "is prepended into signed cookie jar ancestors" do
        ActionDispatch::Cookies::SignedCookieJar.ancestors.first.must_equal SignedCookieJarExtension::ActionPack3
      end

      it "defines initialize" do
        # #initialize doesn't show up in {instance_,}methods({false,true}) for some reason, so do this instead
        # This will throw a NameError if we don't define it
        SignedCookieJarExtension::ActionPack3.instance_method(:initialize)
      end

      describe "signed cookie jar instance with no deprecated token" do
        before do
          @parent_jar = Object.new
          @secret = "a" * 30
          @jar = ActionDispatch::Cookies::SignedCookieJar.new(@parent_jar, @secret)
        end

        it "calls the original initialize method" do
          @jar.instance_variable_get(:@parent_jar).must_equal @parent_jar
        end

        describe "validator" do
          before do
            @verifier = @jar.instance_variable_get(:@verifier)
          end
          it "is a multi message validator" do
            @verifier.must_be_kind_of(MessageMultiVerifier)
          end

          it "has the correct secrets stored" do
            secrets = @verifier.instance_variable_get(:@verifiers).map { |x| x.instance_variable_get(:@secret) }
            secrets.must_equal [@secret]
          end
        end
      end

      describe "signed cookie jar instance with deprecated token" do
        before do
          @parent_jar = Object.new
          @secret = "a" * 30
          @deprecated_secret = "b" * 30
          Rails.application.config.deprecated_secret_token = @deprecated_secret
          @jar = ActionDispatch::Cookies::SignedCookieJar.new(@parent_jar, @secret)
        end

        it "calls the original initialize method" do
          @jar.instance_variable_get(:@parent_jar).must_equal @parent_jar
        end

        describe "validator" do
          before do
            @verifier = @jar.instance_variable_get(:@verifier)
          end
          it "is a multi message validator" do
            @verifier.must_be_kind_of(MessageMultiVerifier)
          end

          it "has the correct secrets stored" do
            secrets = @verifier.instance_variable_get(:@verifiers).map { |x| x.instance_variable_get(:@secret) }
            secrets.must_equal [@secret, @deprecated_secret]
          end
        end
      end

      private

      def load_railtie
        if (init = Rails::Railtie.initializers.first)
          _, _, block = init
          block.call
        end
      end

    end
  end
end
