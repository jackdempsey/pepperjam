module Pepperjam
  class TransactionDetail < Base
    class << self
      def service_url
        base_url + "20120402/publisher/report/transaction-details"
      end

      def find(params = {})
        #validate_params!(params, %w{category promotiontype network pagenumber})
        params.merge!('apiKey' => credentials['api_key'], 'format' => 'json')
        result = get_service(service_url, params)
        Array.wrap(result['data']).map { |transaction_detail| self.new(transaction_detail) }
      end
    end # << self
  end # class
end # module
