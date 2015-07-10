require "rack"
require "action_pack/version"
require "action_dispatch/middleware/cookies"

# Guard in case we're accidentally loaded when rails is
unless defined?(Rails)
  # Fake out rails for testing Hestia::Railtie
  class Rails
    def self.clean
      # Reset everything
      @application = nil
    end

    def self.application
      @application ||= FakeApp.new
    end

    class FakeApp
      def config
        @config ||= FakeConfig.new
      end
    end

    class FakeConfig
      attr_accessor :secret_key_base, :secret_token, :deprecated_secret_token

      # Rails' config respond_to? returns nil if the value of that option is nil
      def respond_to?(name)
        if %i(secret_key_base secret_token deprecated_secret_token).include?(name)
          !!public_send(name)
        end
      end
    end

    # Hestia::Railtie will subclass this
    class Railtie
      def self.initializers
        # Class variable to share with all subclasses
        @@initializers ||= []
      end

      def self.initializer(*args, &block)
        initializers << (args + [block])
      end
    end
  end
end
