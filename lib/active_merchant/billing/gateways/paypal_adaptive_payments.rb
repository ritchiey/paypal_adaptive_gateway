=begin
**************************


**************************
=end

dir = File.dirname(__FILE__)
require dir + '/paypal_adaptive_payments/exceptions.rb'
require dir + '/paypal_adaptive_payments/adaptive_payment_response.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PaypalAdaptivePaymentGateway < Gateway
      
      TEST_URL = 'https://svcs.sandbox.paypal.com/AdaptivePayments/'
      LIVE_URL = 'https://svcs.paypal.com/AdaptivePayments/'
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['US']
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://x.com/'
      
      # The name of the gateway
      self.display_name = 'Paypal Adaptive Payments'
      
      attr_accessor :config_path
      @config_path = "#{RAILS_ROOT}/config/paypal.yml"
      
      def initialize(options = {})
        @config = {}
        if options.empty?
          load_config
        else
          @config.merge! options
        end
      end 
      
      def pay(options)
        commit('Pay', build_adaptive_payment_pay_request(options))
      end                       
    
      def details_for_payment
        
      end
      
      def refund
        
      end
      
      #debug method
      def inspect_data
        "Url: #{@url}\n\n JSON: #{@json} \n\n #{'RESPONSE: ' + @response if @response}"
      end
      
      private                       
      
      #loads config from default file if it is not provided to the constructor
      def load_config
        raise ConfigDoesNotExist if !File.exists?(@config_path);
        @config.merge! Yaml.load_file(@config_path)[RAILS_ENV].symbolize_keys!
      end
      
      def build_adaptive_payment_pay_request opts
        @json = {
          :PayRequest => {
              :actionType => 'PAY',
              :requestEnvelope => {
                :detailLevel => 'ReturnAll',
                :errorLanguage => opts[:error_language] ||= 'en_US'
              },
              :cancelUrl => opts[:cancel_url],
              :returnUrl => opts[:return_url],
              :currencyCode => opts[:currency_code] ||= 'USD',
              :feesPayer => opts[:fees_payer] ||= 'EACHRECEIVER',
              :receiverList => opts[:receiver_list]
            }
          }
          @son[:trackingId] = opts[:tracking_id] if opts[:tracking_id]
          @json[:ipnNotificationUrl] = opts[:ipn_url] if opts[:ipn_url]
          @json = @json.to_json
      end
      
      def parse json
        json
      end     
      
      def commit(action, data)
        @response = parse(post_through_ssl(action, data))
      end
      
      def post_through_ssl(action, parameters = {})
        headers = {
          "X-PAYPAL-REQUEST-DATA-FORMAT" => "JSON",
          "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON",
          "X-PAYPAL-SECURITY-USERID" => @config[:login],
          "X-PAYPAL-SECURITY-PASSWORD" => @config[:password],
          "X-PAYPAL-SECURITY-SIGNATURE" => @config[:signature],
          "X-PAYPAL-APPLICATION-ID" => @config[:appid]
        }
        build_url action
        request = Net::HTTP::Post.new(@url.path)
        request.body = @json
        headers.each_pair { |k,v| request[k] = v }
        request.content_type = 'text/xml'
        server = Net::HTTP.new(@url.host, 443)
        server.use_ssl = true
        server.start { |http| http.request(request) }.body
      end
      
      def endpoint_url
        test? ? TEST_URL : LIVE_URL
      end
      
      def test?
        Base.gateway_mode == :test
      end
      
      def build_url action
        @url = URI.parse(endpoint_url + action)
      end
      
    end
  end
end
