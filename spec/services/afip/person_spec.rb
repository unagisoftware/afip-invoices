# frozen_string_literal: true

require 'test_helper'
require 'support/services/afip/person_support'

describe Afip::Person do
  let(:entity) { create(:entity) }

  before do
    AfipMock.mock_login
    PeopleServiceMock.mock(:ws_wsdl)
  end

  describe '#info' do
    shared_examples 'person details response' do
      it 'returns person details' do
        response = subject.info

        expect(response)
          .to match_valid_representer_format(Afip::PersonSupport::RESPONSE_FORMAT)
      end
    end

    let(:params) { { cuit: '20201797064' } }

    subject { described_class.new(params, entity) }

    context 'when parameters are correct for a responsible person' do
      before do
        PeopleServiceMock.mock(:natural_responsible_person)
      end

      it_behaves_like 'person details response'

      it 'sets person category' do
        expect(subject.info.category).to eq('Responsable inscripto')
      end
    end

    context 'when parameters are correct for a taxpayer person' do
      before do
        PeopleServiceMock.mock(:natural_single_taxpayer_person)
      end

      it_behaves_like 'person details response'

      it 'sets person category' do
        expect(subject.info.category).to eq('Monotributista')
      end
    end

    context 'when parameters are correct for a legal person' do
      before do
        PeopleServiceMock.mock(:legal_person)
      end

      it_behaves_like 'person details response'

      context 'when a response with error is returned from the external service' do
        let!(:people_mock) do
          PeopleServiceMock.mock(:person_with_invalid_address)
        end

        it 'raises an error' do
          expected_message = Hash.from_xml(people_mock.response.body).dig(
            'Envelope',
            'Body',
            'getPersonaResponse',
            'personaReturn',
            'errorConstancia',
            'error',
          )

          expect { subject.info }
            .to raise_error(Afip::ResponseError)
            .with_message("Error de conexión con AFIP: #{expected_message}.")
        end
      end
    end
  end
end
