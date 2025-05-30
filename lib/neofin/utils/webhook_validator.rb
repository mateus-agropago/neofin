# frozen_string_literal: true

require "openssl"
require "base64"

module Neofin
  module Utils
    # Utility class to validate incoming Neofin webhooks using HMAC-SHA256 signature.
    class WebhookValidator
      attr_reader :secret_key

      # @param secret_key [String] The Neofin API Secret Key used for signing.
      def initialize(secret_key:)
        raise ArgumentError, "Secret key cannot be empty" if secret_key.nil? || secret_key.empty?

        @secret_key = secret_key
      end

      # Validates the signature of an incoming webhook request.
      # @param request_body [String] The raw request body received from Neofin.
      # @param signature_header [String] The value of the 'X-Neofin-Hmac-SHA256' header.
      # @return [Boolean] True if the signature is valid, false otherwise.
      def valid?(request_body:, signature_header:)
        return false if request_body.nil? || signature_header.nil? || signature_header.empty?

        begin
          expected_signature_bytes = Base64.strict_decode64(signature_header)
          computed_digest = OpenSSL::HMAC.digest(
            OpenSSL::Digest.new("sha256"),
            secret_key.encode("utf-8"),
            request_body.encode("utf-8")
          )

          OpenSSL.secure_compare(computed_digest, expected_signature_bytes)
        rescue ArgumentError
          false
        rescue OpenSSL::HMACError => e
          warn "[Neofin::WebhookValidator] HMAC calculation error: #{e.message}"
          false
        end
      end
    end
  end
end
