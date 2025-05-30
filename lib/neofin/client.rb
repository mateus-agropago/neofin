# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Neofin
  # The main client class for interacting with the Neofin API.
  class Client
    attr_reader :config

    # @param config [Neofin::Configuration] Configuration object.
    def initialize(config)
      @config = config
      validate_config!
    end

    def billings
      Resources::Billing.new(self)
    end

    def customers
      Resources::Customer.new(self)
    end

    def webhooks
      Resources::Webhook.new(self)
    end

    # Performs an HTTP request to the Neofin API.
    def request(method:, path:, params: {}, body: nil)
      uri = build_uri(path, params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.open_timeout = config.open_timeout
      http.read_timeout = config.timeout

      request = build_request(method, uri, body)

      begin
        response = http.request(request)
        handle_response(response)
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        raise Neofin::Error, "Network error: #{e.message}"
      rescue JSON::ParserError => e
        raise Neofin::Error, "Failed to parse response body: #{e.message}"
      end
    end

    private

    def validate_config!
      raise ConfigurationError, "API Key is missing." unless config.api_key && !config.api_key.empty?
      raise ConfigurationError, "Secret Key is missing." unless config.secret_key && !config.secret_key.empty?
    end

    def build_uri(path, params)
      uri = config.base_uri.dup
      uri.path = path # Directly set the path
      uri.query = URI.encode_www_form(params) unless params.empty?
      uri
    end

    def build_request(method, uri, body)
      http_method_class = case method.downcase.to_sym
                          when :get    then Net::HTTP::Get
                          when :post   then Net::HTTP::Post
                          when :put    then Net::HTTP::Put
                          when :delete then Net::HTTP::Delete
                          else raise ArgumentError, "Unsupported HTTP method: #{method}"
                          end

      request = http_method_class.new(uri.request_uri)
      headers(request)

      if body && %i[post put].include?(method.downcase.to_sym)
        request.body = JSON.generate(body)
        request["Content-Type"] = "application/json"
      end

      request
    end

    def headers(request)
      request["api-key"] = config.api_key
      request["secret-key"] = config.secret_key
      request["Accept"] = "application/json"
      request["User-Agent"] = "neofin-ruby-gem/#{Neofin::VERSION}"
    end

    def handle_response(response)
      status_code = response.code.to_i
      body = response.body
      parsed_body = parse_json_body(body)

      if status_code.between?(200, 299)
        handle_success(parsed_body)
      else
        handle_error(status_code, parsed_body)
      end
    end

    def parse_json_body(body)
      return nil if body.nil? || body.empty?

      JSON.parse(body)
    rescue JSON::ParserError
      body
    end

    def handle_success(parsed_body)
      parsed_body || {}
    end

    def handle_error(status_code, parsed_body)
      message = extract_error_message(parsed_body, "API Error Status #{status_code}")

      case status_code
      when 401
        raise AuthenticationError, message
      when 404
        raise NotFoundError.new(message, status_code, parsed_body)
      when 400, 402..499
        raise ClientError.new(message, status_code, parsed_body)
      when 500..599
        raise ServerError.new(message, status_code, parsed_body)
      else
        raise Error, "Unhandled HTTP status code: #{status_code} - #{message}"
      end
    end

    def extract_error_message(parsed_body, default_message)
      if parsed_body.is_a?(Hash)
        parsed_body["message"] || parsed_body["error"] || parsed_body.dig("errors", 0, "detail") || default_message
      elsif parsed_body.is_a?(String) && !parsed_body.empty?
        parsed_body
      else
        default_message
      end
    end
  end
end
