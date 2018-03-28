# frozen_string_literal: true

class PeopleServiceMock < AfipMock
  ENDPOINT = %r{/sr-padron/webservices/personaServiceA5}i

  def ws_wsdl
    WebMock
      .stub_request(:get, /#{ENDPOINT}\?wsdl$/i)
      .to_return(body: File.read('spec/support/responses/ws_sr_padron_a5_wsdl.xml'))
  end

  def natural_responsible_person
    stub_action(
      soap_action: :get_persona,
      response_body: File.read('spec/support/responses/natural_responsible_person_response.xml'),
    )
  end

  def natural_single_taxpayer_person
    stub_action(
      soap_action: :get_persona,
      response_body: File.read('spec/support/responses/natural_single_taxpayer_person_response.xml'),
    )
  end

  def legal_person
    stub_action(
      soap_action: :get_persona,
      response_body: File.read('spec/support/responses/legal_person_response.xml'),
    )
  end

  def person_with_invalid_address
    stub_action(
      soap_action: :get_persona,
      response_body: File.read('spec/support/responses/person_with_invalid_address.xml'),
    )
  end

  def person_not_found
    stub_action(
      soap_action: :get_persona,
      response_body: File.read('spec/support/responses/person_not_found_response.xml'),
    )
  end

  private

  def endpoint
    ENDPOINT
  end
end
