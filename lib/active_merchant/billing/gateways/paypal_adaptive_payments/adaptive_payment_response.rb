module ActiveMerchant
  module Billing
    module AdaptivePaymentResponses
      
      class AdaptivePaypalSuccessResponse
        
        @redirect_url => 'https://www.paypal.com/webscr?cmd=_ap-payment&paykey='
        
        def initialize json
          @paykey = json['paykey']
          @params = json
        end
        
        def redirect_url_for
          @redirect_url + @paykey
        end
        
        def ack
          @params['responseEnvelope']['ack']
        end
        
        def method_missing
        end
        
      end
      
      class AdaptivePaypalErrorResponse
        
        def error_code
          
        end
        
        def error_message
          
        end
        
      end
      
    end
  end
end