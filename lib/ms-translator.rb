require 'nokogiri'

module Microsoft
  class << self
    # Retun translation. Convenience method for Microsoft::Translator::SOAP.translate
    def Translator(content, from, to)
      Microsoft::Translator::SOAP.translate(content, from, to)
    end
  end
  module Translator
    # Set the application id
    def self.set_app_id(ms_app_id)
      const_set('APP_ID', ms_app_id)
    end

    # Implements a client to the Microsoft translator SOAP API
    class SOAP

      SOAP_ACTION = "http://api.microsofttranslator.com/v1/soap.svc/LanguageService/Translate"
      SOAP_URL = "http://api.microsofttranslator.com/v1/soap.svc"
      SOAP_NS = "http://api.microsofttranslator.com/v1/soap.svc"

      SOAP_BODY = %{<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<soapenv:Body>
<m:Translate xmlns:m="http://api.microsofttranslator.com/v1/soap.svc">
<m:appId>{{APP_ID}}</m:appId>
<m:text>{{TEXT}}</m:text>
<m:from>{{LANG_FROM}}</m:from>
<m:to>{{LANG_TO}}</m:to>
</m:Translate>
</soapenv:Body>
</soapenv:Envelope>}

      def self.translate(content, from, to)
        init_class_vars

        raise "Application id not set! Use `Microsoft::Translator.set_app_id(my_app_id)` to set it." unless Microsoft::Translator.const_defined?('APP_ID')

        @request.body = SOAP_BODY.sub('{{TEXT}}', content).
          sub('{{APP_ID}}', Microsoft::Translator::APP_ID).
          sub('{{LANG_FROM}}', from).sub('{{LANG_TO}}', to)

        response = Net::HTTP.new(@tanslate_uri.host, @tanslate_uri.port).start do |http|
          http.request(@request)
        end

        doc = Nokogiri::XML(response.body)

        doc.xpath('.//mst:TranslateResult/text()', 'mst' => SOAP_NS).to_s
      end

      def self.init_class_vars
        return unless @request.nil? || @tanslate_uri.nil?

        @tanslate_uri = URI.parse(SOAP_URL)

        @request = Net::HTTP::Post.new(@tanslate_uri.path)
        @request.content_type = 'text/xml; charset=utf-8'
        @request['SOAPAction'] = SOAP_ACTION
      end
    end
  end
end
