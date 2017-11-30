require "active_support/message_verifier"
require "active_support/message_encryptor"

module Hestia
  class MessageMultiVerifier

    # Public: creates a verifier for verifying against multiple secrets
    #
    # API compatible with ActiveSupport::MessageVerifier once created. (initializer arguments are different.)
    #
    # current_secret: [String] The current secret token, used for signing *and* verifying cookies
    # deprecated_secrets: [String, Array] The previous secret token(s), used for verifying cookies only
    # options [Hash] options to be passed to the verifiers - see ActiveSupport::MessageVerifier#initialze for details
    #
    def initialize(current_secret:, deprecated_secrets: [], options: {})
      @current_verifier = build_verifier(current_secret, options)
      @deprecated_verifiers = Array(deprecated_secrets).map { |secret| build_verifier(secret, options) }.freeze

      # Generate these here so they are static when accessed in #verify
      @verifiers = [current_verifier, *deprecated_verifiers].freeze

      # Don't need to change any attributes, so why stay mutable?
      freeze
    end

    # Public: generate a signed message
    #
    # Uses only the `current_secret` to generate this.
    #
    # See ActiveSupport::MessageVerifier#generate for more information
    #
    # Returns String
    def generate(value)
      current_verifier.generate(value)
    end

    # Public: verify a signed message and convert back to original form
    #
    # See ActiveSupport::MessageVerifier#verify for more information
    #
    # Returns deserialized value
    # Raises ActiveSupport::MessageVerifier::InvalidSignature
    def verify(signed_message)
      verified(signed_message)
    end

    def verified(signed_message)
      errored_verifier_count = 0

      # Make sure we check *all* verifiers, every time we're called, to prevent timing attacks.
      # We run in a consistent amount of time no matter which (or if any) verifiers return a valid result
      results = verifiers.each_with_object([]) do |verifier, values|
        begin
          values << verifier.verify(signed_message)
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          errored_verifier_count += 1
        end
      end

      # If all the verifiers errored, then none of them thought the message was valid
      if errored_verifier_count == verifiers.size
        raise(ActiveSupport::MessageVerifier::InvalidSignature)
      else
        results.first
      end
    end

    private

    attr_reader :current_verifier, :deprecated_verifiers, :verifiers

    def build_verifier(secret, options)
      ActiveSupport::MessageVerifier.new(secret, options)
    end
  end
end
