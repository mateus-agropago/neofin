# frozen_string_literal: true

module Neofin
  # Base error class for all Neofin specific errors.
  class Error < StandardError; end

  # Raised when API authentication fails (401 Unauthorized).
  class AuthenticationError < Error; end

  # Raised for client-side errors (4xx status codes, excluding 401, 404).
  class ClientError < Error
    attr_reader :response_body, :status_code

    def initialize(message, status_code = nil, response_body = nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  # Raised when a resource is not found (404 Not Found).
  class NotFoundError < ClientError; end

  # Raised for server-side errors (5xx status codes).
  class ServerError < Error
    attr_reader :response_body, :status_code

    def initialize(message = "Neofin server error", status_code = nil, response_body = nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  # Raised for configuration issues.
  class ConfigurationError < Error; end
end
