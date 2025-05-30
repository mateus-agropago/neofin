# frozen_string_literal: true

require "test_helper"

module Neofin
  module Resources
    class CustomerTest < Minitest::Test
      include NeofinTestHelpers

      def setup
        super
        @client = Neofin.client
        @customer_resource = @client.customers
      end

      def test_get_customer_success
        document_number = "30234820000109"

        expected_customer_data = {
          "address_number" => "1231412",
          "address_state" => "RS",
          "recipients" => [],
          "secondary_phone" => "",
          "address_city" => "Porto Alegre",
          "address_complement" => "1234",
          "address_zip_code" => "90619900",
          "name" => "Jose Silva",
          "pause_notifications" => false,
          "address_neighborhood" => "Partenon",
          "situation" => "regular",
          "mail" => "jose.silva@gmail.com",
          "address_street" => "Av.Ipiranga",
          "id" => "e77c9ee-5fa0-4560-b5d3-1c0adf0246be",
          "document" => document_number,
          "phone" => "+5551982944152"
        }
        # ***** END FIX *****

        stub_neofin_request(
          :get,
          "/customer/#{document_number}",
          response_body: expected_customer_data, # Still pass Hash, stub helper handles JSON.generate
          status: 200
        )

        response = @customer_resource.get(document_number: document_number)

        # Assertion should now pass as both hashes use string keys
        assert_equal expected_customer_data, response

        WebMock.assert_requested(
          :get,
          "#{@sandbox_base_url}/customer/#{document_number}",
          headers: expected_headers
        )
      end

      def test_get_customer_requires_document_number
        assert_raises(ArgumentError) { @customer_resource.get(document_number: nil) }
        assert_raises(ArgumentError) { @customer_resource.get(document_number: "") }
      end

      def test_get_customer_not_found
        document_number = "00000000000000"
        # Use string keys here too for consistency, though it might not strictly matter for error body
        error_response = { "message" => "Customer not found" }

        stub_neofin_error(
          :get,
          "/customer/#{document_number}",
          error_body: error_response,
          status: 404
        )

        # This assertion should now pass because the correct NotFoundError will propagate
        exception = assert_raises(Neofin::NotFoundError) do
          @customer_resource.get(document_number: document_number)
        end

        # These assertions remain the same
        assert_match(/Customer not found/i, exception.message)
        assert_equal 404, exception.status_code
        # Compare response_body which should be hash with string keys
        assert_equal error_response, exception.response_body

        WebMock.assert_requested(
          :get,
          "#{@sandbox_base_url}/customer/#{document_number}",
          headers: expected_headers
        )
      end

      # test_upsert_customer_success remains the same - assumes it was working
      def test_upsert_customer_success
        customer_payload = [{
          "document" => "12345678000199",
          "name" => "Upsert Test Inc.",
          "mail" => "upsert@test.com",
          "address_city" => "Testville",
          "address_complement" => "Suite 100",
          "address_neighborhood" => "Downtown",
          "address_number" => "123",
          "address_state" => "TS",
          "address_street" => "Main St",
          "address_zip_code" => "12345-000",
          "phone" => "+5511999998888",
          "integration_identifier" => "upsert-test-id",
          "pause_notifications" => false,
          "recipients" => ["finance@test.com"]
        }]
        expected_request_body = { customers: customer_payload }
        expected_response = { "message" => "Customers processed successfully.", "errors" => {} }

        stub_neofin_request(
          :post,
          "/customer/",
          request_body: expected_request_body,
          response_body: expected_response,
          status: 200
        )

        response = @customer_resource.upsert(customers: customer_payload)

        assert_equal expected_response, response
        WebMock.assert_requested(
          :post,
          "#{@sandbox_base_url}/customer/",
          body: JSON.generate(expected_request_body),
          headers: expected_headers.merge({ "Content-Type" => "application/json" })
        )
      end
    end
  end
end
