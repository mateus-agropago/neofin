# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require "time"

require_relative "neofin/version"
require_relative "neofin/error"
require_relative "neofin/configuration"
require_relative "neofin/client"
require_relative "neofin/resources/base_resource"
require_relative "neofin/resources/billing"
require_relative "neofin/resources/customer"
require_relative "neofin/resources/webhook"
require_relative "neofin/utils/webhook_validator"

# Main module for the Neofin gem.
module Neofin
  class << self
    attr_writer :configuration

    # Provides access to the configuration instance.
    # Initializes a default configuration if none exists.
    def configuration
      @configuration ||= Configuration.new
    end

    # Allows configuration via a block.
    # Example:
    # Neofin.configure do |config|
    #   config.api_key = 'your_api_key'
    #   config.secret_key = 'your_secret_key'
    #   config.environment = :production
    # end
    def configure
      yield(configuration)
    end

    # Resets the configuration to defaults. Useful for testing.
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Creates a new Neofin client instance with the current configuration.
    # Optionally accepts overrides for configuration parameters.
    # @param options [Hash] Configuration overrides (api_key, secret_key, environment, timeout, open_timeout)
    # @return [Neofin::Client] An instance of the Neofin client.
    def client(options = {})
      config = configuration.dup # Start with global config
      options.each do |key, value|
        config.send("#{key}=", value) if config.respond_to?("#{key}=")
      end
      Client.new(config)
    end
  end
end
