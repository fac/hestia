require_relative "../spec_helper"
require "action_pack/version"

module Hestia
  describe MessageMultiVerifier do
    InvalidSignature = ActiveSupport::MessageVerifier::InvalidSignature

    let(:message_verifier) { ActiveSupport::MessageVerifier.new("secret") }
    let(:singular_verifier) { MessageMultiVerifier.new(current_secret: "secret") }
    let(:multi_verifier) { MessageMultiVerifier.new(current_secret: "secret", deprecated_secrets: %w(previous_secret)) }

    describe "creation" do
      it "requires a current secret" do
        -> { MessageMultiVerifier.new }.must_raise(ArgumentError, /current_secret/)
      end

      it "can be created with current & deprecated secrets" do
        MessageMultiVerifier.new(current_secret: "secret", deprecated_secrets: %w(previous_secret legacy_secret))
      end

      it "can be created with current secret & options only" do
        MessageMultiVerifier.new(current_secret: "secret", options: {digest: "MD5"})
      end

      it "can be created with array of secrets and options for the verifiers" do
        MessageMultiVerifier.new(current_secret: "secret", deprecated_secrets: %w(previous_secret), options: {digest: "MD5"})
      end

      it "is immutable after creation" do
        multi_verifier.must_be :frozen?
      end
    end

    describe "generating messages with one secret set" do
      it "is generated using first secret" do
        singular_verifier.generate("cookie dough").must_equal message_verifier.generate("cookie dough")
      end
    end

    describe "generating messages with multiple secrets set" do
      it "is generated using first secret" do
        multi_verifier.generate("cookie dough").must_equal message_verifier.generate("cookie dough")
      end
    end

    describe "verify behaviour" do
      let(:legacy_message_verifier) { ActiveSupport::MessageVerifier.new("previous_secret") }

      let(:current_cookie) { message_verifier.generate("cookie dough") }
      let(:legacy_cookie) { legacy_message_verifier.generate("cookie dough") }

      it "errors when given blank message" do
        -> { multi_verifier.verify(nil) }.must_raise(InvalidSignature)
        -> { singular_verifier.verify("") }.must_raise(InvalidSignature)

        -> { multi_verifier.verify(nil) }.must_raise(InvalidSignature)
        -> { multi_verifier.verify("") }.must_raise(InvalidSignature)
      end

      it "errors without -- delimited data/digest" do
        invalid_cookie = current_cookie.gsub("--", "-")
        -> { singular_verifier.verify(invalid_cookie) }.must_raise(InvalidSignature)
        -> { multi_verifier.verify(invalid_cookie) }.must_raise(InvalidSignature)
      end

      it "errors without data being present" do
        invalid_cookie = current_cookie.gsub(/\A.+--/, "")
        -> { singular_verifier.verify(invalid_cookie) }.must_raise(InvalidSignature)
        -> { multi_verifier.verify(invalid_cookie) }.must_raise(InvalidSignature)
      end

      it "errors without digest being present" do
        invalid_cookie = current_cookie.gsub(/--.+\z/, "")
        -> { singular_verifier.verify(invalid_cookie) }.must_raise(InvalidSignature)
        -> { multi_verifier.verify(invalid_cookie) }.must_raise(InvalidSignature)
      end

      it "errors without passed in digest matching computed digest" do
        invalid_cookie = current_cookie.gsub(/^.+--/, "lol_error_not_a_digest_zomg")
        -> { singular_verifier.verify(invalid_cookie) }.must_raise(InvalidSignature)
        -> { multi_verifier.verify(invalid_cookie) }.must_raise(InvalidSignature)
      end

      it "errors with cookie signed using unknown secret" do
        -> { singular_verifier.verify(legacy_cookie) }.must_raise(InvalidSignature)
      end

      it "verifies successfully with correct payload for any valid secret" do
        singular_verifier.verify(current_cookie).must_equal "cookie dough"

        multi_verifier.verify(current_cookie).must_equal "cookie dough"
        multi_verifier.verify(legacy_cookie).must_equal "cookie dough"
      end

      if ActionPack::VERSION::MAJOR < 5
        it "verifies a message of `nil' successfully" do
          nil_cookie = singular_verifier.generate(nil)

          singular_verifier.verify(nil_cookie).must_equal(nil)
          multi_verifier.verify(nil_cookie).must_equal(nil)
        end
      end

      it "verifies successfully when using custom digest" do
        multi_singular_secret = MessageMultiVerifier.new(current_secret: "secret", options: {digest: "MD5"})
        multi_multiple_secret = MessageMultiVerifier.new(current_secret: "secret", deprecated_secrets: %w(previous_secret), options: {digest: "MD5"})

        current_cookie = ActiveSupport::MessageVerifier.new("secret", :digest => "MD5").generate("cookie dough")
        previous_cookie = ActiveSupport::MessageVerifier.new("previous_secret", :digest => "MD5").generate("cookie dough")

        multi_singular_secret.verify(current_cookie).must_equal "cookie dough"
        multi_multiple_secret.verify(current_cookie).must_equal "cookie dough"
        multi_multiple_secret.verify(previous_cookie).must_equal "cookie dough"
      end

      it "verifies successfully when using custom serializer" do
        reverser = Module.new do
          extend self

          def dump(string)
            string.reverse
          end

          alias_method :load, :dump
        end

        multi_singular_secret = MessageMultiVerifier.new(current_secret: "secret", options: {serializer: reverser})
        multi_multiple_secret = MessageMultiVerifier.new(current_secret: "secret", deprecated_secrets: %w(previous_secret), options: {serializer: reverser})

        current_cookie = ActiveSupport::MessageVerifier.new("secret", :serializer => reverser).generate("cookie dough")
        previous_cookie = ActiveSupport::MessageVerifier.new("previous_secret", :serializer => reverser).generate("cookie dough")

        multi_singular_secret.verify(current_cookie).must_equal "cookie dough"
        multi_multiple_secret.verify(current_cookie).must_equal "cookie dough"
        multi_multiple_secret.verify(previous_cookie).must_equal "cookie dough"
      end
    end
  end
end
