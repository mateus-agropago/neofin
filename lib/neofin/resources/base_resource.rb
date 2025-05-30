# frozen_string_literal: true

module Neofin
  module Resources
    # Base class for API resource interactions.
    class BaseResource
      attr_reader :client

      # @param client [Neofin::Client] The client instance to use for requests.
      def initialize(client)
        @client = client
      end

      private

      # Helper methods to delegate requests to the client
      def get_request(path, params = {})
        client.request(method: :get, path: path, params: params)
      end

      def post_request(path, body = {})
        client.request(method: :post, path: path, body: body)
      end

      def put_request(path, body = {})
        client.request(method: :put, path: path, body: body)
      end

      # Add delete_request if needed
    end
  end
end
