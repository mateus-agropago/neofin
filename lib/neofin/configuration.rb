# frozen_string_literal: true

module Neofin
  # Manages configuration settings for the Neofin client.
  class Configuration
    attr_accessor :api_key, :secret_key, :timeout, :open_timeout
    attr_reader :base_uri, :environment # Derived from environment

    # Available environments and their base URIs [source: 164]
    ENVIRONMENTS = {
      sandbox: URI("https://api.sandbox.neofin.services/"),
      production: URI("https://api.neofin.services/")
    }.freeze

    def initialize
      # Set defaults via accessors where possible to ensure logic runs
      self.environment = :sandbox # Default environment (calls setter below)
      @timeout = 60          # Default request timeout in seconds
      @open_timeout = 30     # Default connection open timeout in seconds
      # No direct call to set_base_uri here anymore
    end

    # Sets the environment and updates the base URI accordingly.
    def environment=(env)
      env_sym = env.to_sym
      unless ENVIRONMENTS.key?(env_sym)
        # Assuming ConfigurationError is defined elsewhere or change to ArgumentError
        raise ConfigurationError, "Invalid environment: #{env}. Valid environments are: #{ENVIRONMENTS.keys.join(", ")}"
      end

      @environment = env_sym # Set the instance variable
      set_base_uri # Update the base URI
    end

    private

    # Sets the base URI based on the current environment.
    def set_base_uri
      @base_uri = ENVIRONMENTS[@environment]
    end
  end
end
