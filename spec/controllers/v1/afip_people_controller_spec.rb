# frozen_string_literal: true

require 'test_helper'
require 'shared_examples/shared_examples_for_controllers'
require 'support/controllers/afip_people_controller_support'

describe V1::AfipPeopleController, type: :controller do
  let(:entity) { create(:entity) }

  before do
    AfipMock.mock_login
    PeopleServiceMock.mock(:ws_wsdl)

    request.headers['HTTP_AUTHORIZATION'] = "Token token=\"#{entity.auth_token}\""
  end

  describe 'GET show' do
    subject { get :show, params: { cuit: '20201797064' } }

    context 'when person exists' do
      before do
        PeopleServiceMock.mock(:natural_responsible_person)
      end

      it_behaves_like 'HTTP 200 response'

      it 'renders person details' do
        subject

        data = JSON.parse(response.body).symbolize_keys

        expect(data).not_to be_empty
        expect(data).to match_valid_format(
          AfipPeopleControllerSupport::RESPONSE_FORMAT,
        )
      end
    end

    context 'when person cannot be found' do
      before do
        PeopleServiceMock.mock(:person_not_found)
      end

      it_behaves_like 'HTTP 502 response'

      it 'renders an error' do
        get :show, params: { cuit: '20201797064' }

        data = JSON.parse(response.body)

        expect(data).not_to be_empty
        expect(data['error']).to include('No existe persona con ese Id')
      end
    end

    context 'when a response with error is returned from the external service' do
      before do
        PeopleServiceMock.mock(:person_with_invalid_address)
      end

      it_behaves_like 'HTTP 502 response'

      it 'renders an error' do
        get :show, params: { cuit: '20201797064' }

        parsed_body = JSON.parse(response.body)

        expect(parsed_body).not_to be_empty
        expect(parsed_body['error']).not_to be_nil
      end
    end
  end
end
