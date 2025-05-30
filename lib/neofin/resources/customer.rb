# frozen_string_literal: true

module Neofin
  module Resources
    # Interface for interacting with the /customers API endpoints.
    class Customer < BaseResource
      RESOURCE_PATH = "/customer/"

      # Creates or updates one or more customers.
      # Queues up to 50 customers at a time. Does not return customer data directly.
      # @param customers [Array<Hash>] An array of customer data hashes. See API docs for parameters.
      # @return [Hash] API response indicating success or failure of queuing. (Expected similar to billing create)
      def upsert(customers:)
        raise ArgumentError, "customers must be an Array" unless customers.is_a?(Array)

        payload = { customers: customers }
        post_request(RESOURCE_PATH, payload)
      end

      def get(document_number:)
        raise ArgumentError, "document_number cannot be empty" if document_number.nil? || document_number.empty?

        path = "#{RESOURCE_PATH}#{document_number}"
        get_request(path)
      end

      # Lists all customers associated with the account, with optional filters.
      # @param params [Hash] Optional query parameters for filtering (e.g., status, integration_identifier)
      # @return [Hash] API response containing a list of customers.
      def list(params = {})
        get_request(RESOURCE_PATH, params)
      end
    end
  end
end
