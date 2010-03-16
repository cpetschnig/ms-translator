require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Microsoft::Translator" do
  it "translates" do
    FakeWeb.register_uri(:post, Microsoft::Translator::SOAP::SOAP_URL,
      :body => '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><TranslateResponse xmlns="http://api.microsofttranslator.com/v1/soap.svc"><TranslateResult>I just got translated!</TranslateResult></TranslateResponse></s:Body></s:Envelope>',
      :status => ["200", "OK"])

    Microsoft::Translator.set_app_id('MOCK_MY_APP_ID')

    translated = Microsoft::Translator::SOAP.translate('Translate me!', 'klingon', 'mordor')

    translated.should == 'I just got translated!'
  end
end
