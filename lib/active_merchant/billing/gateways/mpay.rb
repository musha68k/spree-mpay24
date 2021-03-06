require 'net/http'
require 'uri'

module ActiveMerchant
  module Billing
    class MPayGateway < Gateway

      self.test_mode = true
      self.test_redirect_url = 'https://test.mPAY24.com/app/bin/etpv5';
      self.test_merchant_id = '92035'
      self.production_merchant_id = '72035'
      self.production_redirect_url = 'https://www.mpay24.com/app/bin/etpv5';

      # move this to the other thing?
      def gateway_url
        self.test_mode == true ? self.test_redirect_url : self.production_redirect_url
      end

      def merchant_id
        self.test_mode == true ? self.test_merchant_id : self.production_merchant_id
      end

      def setup_authorization(money, options = {})
        # TODO: howto use the options infrastructure
        merchant_id = merchant_id
        operation = 'SELECTPAYMENT'

        # TODO: merge options

        # build MDXI XML Block
        xml = Bulder::XmlMarkup.new
        xml.tag! 'order' do
          xml.tag! 'Tid', 'some order identifier'
          xml.tag! 'ShoppingCart' do
            xml.tag! 'Description', 'some description'
          end

          xml.tag! 'price', amount(money)
          xml.tag! 'BillingAddr', :mode => 'ReadWrite' do
            xml.tag! 'Name', options[:shipping_address][:name]
            xml.tag! 'City', options[:shipping_address][:city]
            xml.tag! 'Street', options[:shipping_address][:street]
            #TODO: add more address stuff from options hash
          end

          xml.tag! 'URL' do
            xml.tag! 'Confirmation', 'some-confirmation-url'
            xml.tag! 'Notifcation', mpay_callbacks_url
          end
        end

        cmd = xml.build!

        # build and send the command
        res = Net::HTTP.post_form(URI.parse(self.test_redirect_url),
                              {
                                'operation' => operation,
                                'merchant_id' => merchant_id,
                                'MDXI' => cmd
                              })

        # extract information
        raise res.inspect

    #3: Detailed control
    #url = URI.parse('http://www.example.com/todo.cgi')
    #req = Net::HTTP::Post.new(url.path)
    #req.basic_auth 'jack', 'pass'
    #req.set_form_data({'from'=>'2005-01-01', 'to'=>'2005-03-31'}, ';')
    #res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    #case res
    #when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
    #else
    #  res.error!
    #end
        
        # render the corresponding URL in an IFRAME
        render :partial => 'shared/mpay_confirm',
               :locals => { :iframe_url => "fubar" },
               :layout => true
      end

      def authorize(money, options={})
        raise "mpaygateway.authorize called".inspect
      end

      def purchase(money, options={})
        raise "mpaygateway.purchase called".inspect
      end
    end
  end
end
