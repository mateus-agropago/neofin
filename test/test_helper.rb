# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "neofin"

require "minitest/autorun"
require "webmock/minitest"

# Disable external network connections during tests
WebMock.disable_net_connect!(allow_localhost: true)

# Helper methods for tests
module NeofinTestHelpers
  def setup
    Neofin.reset_configuration!
    WebMock.reset!

    # Default valid config
    @api_key = "test_api_key"
    @secret_key = "test_secret_key"
    Neofin.configure do |config|
      config.api_key = @api_key
      config.secret_key = @secret_key
      config.environment = :sandbox # Default test env
    end
    @sandbox_base_url = "https://api.sandbox.neofin.services"
  end

  def teardown
    WebMock.reset!
    Neofin.reset_configuration!
  end

  def stub_neofin_request(method, path, response_body: {}, query: {}, request_body: nil, status: 200) # rubocop:disable Metrics/ParameterLists
    url = "#{@sandbox_base_url}#{path}"
    url += "?#{URI.encode_www_form(query)}" unless query.empty?

    stub = WebMock.stub_request(method, url)
    stub.with(headers: expected_headers)

    if request_body
      stub.with(body: request_body.is_a?(String) ? request_body : JSON.generate(request_body),
                headers: { "Content-Type" => "application/json" })
    end

    stub.to_return(
      status: status,
      body: JSON.generate(response_body),
      headers: { "Content-Type" => "application/json" }
    )
  end

  # Stubs a failed Neofin API request
  def stub_neofin_error(method, path, error_body: {}, status: 400)
    url = "#{@sandbox_base_url}#{path}"
    stub = WebMock.stub_request(method, url)
    stub.with(headers: expected_headers)
    stub.to_return(
      status: status,
      body: JSON.generate(error_body),
      headers: { "Content-Type" => "application/json" }
    )
  end

  def expected_headers
    {
      "Accept" => "application/json",
      "Api-Key" => @api_key,
      "Secret-Key" => @secret_key,
      "User-Agent" => "neofin-ruby-gem/#{Neofin::VERSION}"
    }
  end
end
