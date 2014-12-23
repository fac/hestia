require "rack"
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
      @application ||= OpenStruct.new(:config => OpenStruct.new)
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
