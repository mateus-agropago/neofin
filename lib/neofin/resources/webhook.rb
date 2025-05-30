# frozen_string_literal: true

module Neofin
  module Resources
    # Interface for interacting with the /webhook API endpoints (registration).
    class Webhook < BaseResource
      RESOURCE_PATH = "/webhook"

      # Registers a webhook endpoint for a specific topic.
      # @param topic [String] The event topic (e.g., 'payments/created'). See API docs for valid topics.
      # @param destination [String] The HTTPS URL to receive the webhook POST requests.
      # @return [Hash] API response indicating success or failure. (Response format not specified, assuming standard)
      def register(topic:, destination:)
        # Basic validation
        raise ArgumentError, "Webhook destination URL must use HTTPS" unless destination.start_with?("https://")

        # Add topic validation if desired based on [source: 298]
        payload = { topic: topic, destination: destination }
        post_request(RESOURCE_PATH, payload)
      end
    end
  end
end
