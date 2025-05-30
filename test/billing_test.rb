# frozen_string_literal: true

require "test_helper"

module Neofin
  module Resources
    class BillingTest < Minitest::Test
      include NeofinTestHelpers

      def setup
        super
        @client = Neofin.client
        @billing_resource = @client.billings
      end

      def test_create_billing_success
        anonymized_billing_data = {
          "address_city" => "Florianopolis",
          "address_complement" => "Apt 501",
          "address_neighborhood" => "Centro",
          "address_number" => "100",
          "address_state" => "SC",
          "address_street" => "Rua Exemplo Principal",
          "address_zip_code" => "88010000",
          "amount" => 15_000,
          "by_mail" => true,
          "by_whatsapp" => true,
          "customer_document" => "12345678000199",
          "customer_mail" => "contato@exemploempresa.com",
          "customer_name" => "Empresa Exemplo Ltda",
          "customer_phone" => "+5548999998888",
          "customer_secondary_phone" => "",
          "discount_before_payment" => 0,
          "discount_before_payment_due_date" => 0,
          "due_date" => Time.now.to_i + (60 * 60 * 24 * 30),
          "fees" => 1,
          "fine" => 2,
          "integration_identifier" => "myapp-test-billing-id",
          "installment_type" => "custom",
          "installments" => 1,
          "installments_data" => [
            {
              "amount" => 15_000,
              "due_date" => Time.now.to_i + (60 * 60 * 24 * 30),
              "installment_number" => 1
            }
          ],
          "nfe_number" => "98765",
          "recipients" => ["financeiro@exemploempresa.com"],
          "type" => "pix",
          "origin" => "test-suite"
        }

        payload_to_send = [anonymized_billing_data]
        expected_request_body = { billings: payload_to_send }

        expected_response = { "message" => "Billings successfully queued.", "errors" => {} }

        stub_neofin_request(
          :post,
          "/billing",
          request_body: expected_request_body,
          response_body: expected_response,
          status: 200
        )

        response = @billing_resource.create(billings: payload_to_send)

        assert_equal expected_response, response

        WebMock.assert_requested(
          :post,
          "#{@sandbox_base_url}/billing",
          body: JSON.generate(expected_request_body),
          headers: expected_headers.merge({ "Content-Type" => "application/json" })
        )
      end

      def test_create_billing_requires_array
        assert_raises(ArgumentError) { @billing_resource.create(billings: { name: "wrong type" }) }
      end

      def test_get_billing_success
        billing_number = "1234567890"
        expected_response = { "billing_number" => billing_number, "amount" => 5000.0, "status" => "pending" }

        stub_neofin_request(
          :get,
          "/billing/#{billing_number}",
          response_body: expected_response # Pass Hash, helper converts to JSON
        )

        response = @billing_resource.get(billing_number: billing_number)

        assert_equal expected_response, response
        WebMock.assert_requested(:get, "#{@sandbox_base_url}/billing/#{billing_number}", headers: expected_headers)
      end

      def test_get_billing_not_found
        billing_number = "nonexistent"
        error_response = { "message" => "Billing not found" }

        stub_neofin_error(:get, "/billing/#{billing_number}", error_body: error_response, status: 404)

        exception = assert_raises(Neofin::NotFoundError) do
          @billing_resource.get(billing_number: billing_number)
        end

        assert_match(/Billing not found/i, exception.message)
        assert_equal 404, exception.status_code
        assert_equal error_response, exception.response_body

        WebMock.assert_requested(:get, "#{@sandbox_base_url}/billing/#{billing_number}", headers: expected_headers)
      end

      def test_update_billing_success
        billing_number = "987654"
        update_attrs = { "amount" => 12_000, "customer_name" => "Updated Name Inc." } # amount in cents
        expected_response = { "message" => "Billing update successfully queued.", "errors" => {} }

        stub_neofin_request(:put, "/billing/#{billing_number}",
                            request_body: update_attrs, # Pass Hash
                            response_body: expected_response,
                            status: 200)

        response = @billing_resource.update(billing_number: billing_number, attributes: update_attrs)

        assert_equal expected_response, response
        WebMock.assert_requested(:put, "#{@sandbox_base_url}/billing/#{billing_number}",
                                 body: JSON.generate(update_attrs),
                                 headers: expected_headers.merge({ "Content-Type" => "application/json" }))
      end

      def test_mark_as_paid_success
        billing_number = "paid123"
        expected_response = { "message" => "Billing successfully paid.", "errors" => {} }

        stub_neofin_request(:put, "/billing/paid/#{billing_number}", response_body: expected_response)

        response = @billing_resource.mark_as_paid(billing_number: billing_number)

        assert_equal expected_response, response
        WebMock.assert_requested(:put, "#{@sandbox_base_url}/billing/paid/#{billing_number}", headers: expected_headers)
      end

      def test_cancel_billing_success
        billing_number = "cancel456"
        expected_response = { "message" => "Billing successfully canceled.", "errors" => {} }

        stub_neofin_request(:put, "/billing/cancel/#{billing_number}", response_body: expected_response)

        response = @billing_resource.cancel(billing_number: billing_number)

        assert_equal expected_response, response
        WebMock.assert_requested(:put, "#{@sandbox_base_url}/billing/cancel/#{billing_number}",
                                 headers: expected_headers)
      end

      def test_upload_nf_success
        billing_number = "nf789"
        base64_pdf = "JVBERi0xLjMKJ..."
        expected_request_body = { "nf_file" => base64_pdf }
        expected_response = { "message" => "NF successfully uploaded.", "errors" => {} }

        stub_neofin_request(:put, "/billing/nfupload/#{billing_number}",
                            request_body: expected_request_body,
                            response_body: expected_response)

        response = @billing_resource.upload_nf(billing_number: billing_number, nf_file_base64: base64_pdf)

        assert_equal expected_response, response
        WebMock.assert_requested(:put, "#{@sandbox_base_url}/billing/nfupload/#{billing_number}",
                                 body: JSON.generate(expected_request_body),
                                 headers: expected_headers.merge({ "Content-Type" => "application/json" }))
      end

      def test_list_billings_success
        expected_response = { "billings" => [{ "billing_number" => "1" }, { "billing_number" => "2" }] }

        stub_neofin_request(:get, "/billing", response_body: expected_response)

        response = @billing_resource.list

        assert_equal expected_response, response
        WebMock.assert_requested(:get, "#{@sandbox_base_url}/billing", headers: expected_headers)
      end
    end
  end
end
