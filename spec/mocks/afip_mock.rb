# frozen_string_literal: true

require 'webmock'

class AfipMock
  SOAP_HEADERS = {
    headers: {
      'Content-Type' => 'text/xml;charset=UTF-8',
    }.freeze
  }.freeze

  def self.mock(method)
    mock_object.send(method)
  end

  def self.mock_login
    mock(:login_wsdl)
    mock(:login)
  end

  def login_wsdl
    WebMock
      .stub_request(:get, /LoginCms\?wsdl$/)
      .to_return(body: File.new('spec/support/responses/wsaa_wsdl.xml').read)
  end

  def login
    WebMock
      .stub_request(:post, /LoginCms$/)
      .to_return(body: File.new('spec/support/responses/login_response.xml').read)
  end

  class << self
    private

    def mock_object
      @mock_object ||= new
    end
  end

  private

  def stub_action(soap_action:, response_body:, status: 200)
    params = build_params(soap_action)

    WebMock
      .stub_request(:post, endpoint)
      .with(params)
      .to_return(
        status: status,
        body: response_body,
        headers: {content_type: 'text/xml;charset=UTF-8'},
      )
  end

  def build_params(soap_action)
    action = soap_action.to_s.delete('_')

    SOAP_HEADERS.deep_merge(
      body: /./,
      headers: {'SOAPAction' => /#{Regexp.quote(action)}/i},
    )
  end
end
