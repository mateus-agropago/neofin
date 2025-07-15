# frozen_string_literal: true

module Neofin
  module Resources
    # Interface for interacting with the /billing API endpoints.
    class Billing < BaseResource
      RESOURCE_PATH = "/billing"

      # Creates one or more billings.
      # Queues up to 50 billings at a time. Does not return billing data directly.
      # @param billings [Array<Hash>] An array of billing data hashes. See API docs for parameters.
      # @return [Hash] API response indicating success or failure of queuing.
      def create(billings:)
        raise ArgumentError, "billings must be an Array" unless billings.is_a?(Array)

        post_request(RESOURCE_PATH, { billings: billings })
      end

      # Retrieves a specific billing by its number.
      # @param integration_identifier [String] The unique identifier of the billing.
      # @return [Hash] The billing data.
      def get(integration_identifier:)
        get_request("#{RESOURCE_PATH}/integration/#{integration_identifier}")
      end

      # Updates an existing billing.
      # @param billing_number [String, Integer] The unique identifier of the billing to update.
      # @param attributes [Hash] A hash of attributes to update. See API docs for editable fields.
      # @return [Hash] API response indicating success or failure of queuing the update.
      def update(billing_number:, attributes:)
        put_request("#{RESOURCE_PATH}/#{billing_number}", attributes)
      end

      # Marks an invoice as paid, primarily for 'generic' types.
      # @param billing_number [String, Integer] The unique identifier of the billing.
      # @return [Hash] API response indicating success.
      def mark_as_paid(billing_number:)
        put_request("#{RESOURCE_PATH}/paid/#{billing_number}")
      end

      # Cancels an invoice if its status is 'pending' or 'overdue'.
      # @param billing_number [String, Integer] The unique identifier of the billing.
      # @return [Hash] API response indicating success.
      def cancel(billing_number:)
        put_request("#{RESOURCE_PATH}/cancel/#{billing_number}")
      end

      # Uploads a DANFE file (PDF) for a specific billing.
      # @param billing_number [String, Integer] The unique identifier of the billing.
      # @param nf_file_base64 [String] The Base64 encoded content of the PDF file.
      # @return [Hash] API response indicating success.
      def upload_nf(billing_number:, nf_file_base64:)
        put_request("#{RESOURCE_PATH}/nfupload/#{billing_number}", { nf_file: nf_file_base64 })
      end

      # Lists all invoices associated with the account.
      # @param params [Hash] Optional query parameters for filtering/pagination
      # @return [Hash] API response containing a list of billings.
      def list(params = {})
        get_request(RESOURCE_PATH, params)
      end

      # Lists all invoices filtered by integration_identifier.
      # @param integration_identifier [String] The integration identifier to filter by.
      # @param params [Hash] Optional additional query parameters.
      # @return [Hash] API response containing a list of billings.
      def list_by_integration_identifier(integration_identifier, params = {})
        params = params.merge({ integration_identifier: integration_identifier })
        list(params)
      end

      # Lists all invoices filtered by status.
      # @param status [String] The status to filter by (e.g., 'pending', 'paid', etc.).
      # @param params [Hash] Optional additional query parameters.
      # @return [Hash] API response containing a list of billings.
      def list_by_status(status, params = {})
        params = params.merge({ status: status })
        list(params)
      end

      # Lists billings by payment date range.
      # @param start_paid_at_date [String] ISO 8601 date string. Required. Returns payments from this date onwards.
      # @param end_paid_at_date [String, nil] ISO 8601 date string. Optional. Returns payments up to this date.
      # @param params [Hash] Optional additional query parameters.
      # @return [Hash] API response containing a list of billings/installments.
      def list_by_payment_date(start_paid_at_date:, end_paid_at_date: nil, params: {})
        raise ArgumentError, "start_paid_at_date is required" if start_paid_at_date.nil? || start_paid_at_date.empty?
        query = params.merge({ start_paid_at_date: start_paid_at_date })
        query[:end_paid_at_date] = end_paid_at_date if end_paid_at_date
        get_request("/billing/installment/by_payment_date", query)
      end
    end
  end
end
