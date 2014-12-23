require "rack"
require "action_dispatch/middleware/cookies"

# Guard in case we're accidentally loaded when rails is
unless defined?(Rails)

  # Fake out rails for testing Hestia::Railtie
  class Rails
    # Put them here to avoid subclass issues
    def self.initializers
      @initializers ||= []
    end

    # Hestia::Railtie will subclass this
    class Railtie
      def self.initializer(*args, &block)
        # Store it on the Rails singleton attribute to work around subclass scoping issues
        Rails.initializers << (args + [block])
      end
    end
  end
end
