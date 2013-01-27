module Pepperjam
  class Coupon < Base
    class << self
      def service_url
        base_url + "20120402/publisher/creative/coupon"
      end

      def find(params = {})
        #validate_params!(params, %w{category promotiontype network pagenumber})
        params.merge!('apiKey' => credentials['api_key'], 'format' => 'json')
        result = get_service(service_url, params)
        Array.wrap(result['data']).map { |coupon| self.new(coupon) }
      end

    end # << self

    def link_id
      id
    end

    def advertiser_id
      program_id
    end

  end # class
end # module
