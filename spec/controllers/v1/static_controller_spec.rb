# frozen_string_literal: true

require 'test_helper'
require 'shared_examples/shared_examples_for_controllers'
require 'support/controllers/static_controller_support'

describe V1::StaticController, type: :controller do
  let(:entity) { create(:entity) }

  before do
    AfipMock.mock_login
    InvoicesServiceMock.mock(:ws_wsdl)

    request.headers['HTTP_AUTHORIZATION'] = "Token token=\"#{entity.auth_token}\""
  end

  shared_examples 'list of elements renderer' do
    it 'renders a list of elements' do
      subject

      expect(JSON.parse(response.body)).not_to be_empty
    end
  end

  describe 'GET bill_types' do
    before { InvoicesServiceMock.mock(:bill_types) }

    subject { get :bill_types }

    it_behaves_like 'HTTP 200 response'
    it_behaves_like 'list of elements renderer'
  end

  describe 'GET concept_types' do
    before { InvoicesServiceMock.mock(:concept_types) }

    subject { get :concept_types }

    it_behaves_like 'HTTP 200 response'
    it_behaves_like 'list of elements renderer'
  end

  describe 'GET currencies' do
    before { InvoicesServiceMock.mock(:currencies) }

    subject { get :currencies }

    it_behaves_like 'HTTP 200 response'
    it_behaves_like 'list of elements renderer'
  end

  describe 'GET tax_types' do
    before { InvoicesServiceMock.mock(:tax_types) }

    subject { get :tax_types }

    it_behaves_like 'HTTP 200 response'
    it_behaves_like 'list of elements renderer'
  end

  describe 'GET document_types' do
    before { InvoicesServiceMock.mock(:document_types) }

    subject { get :document_types }

    it_behaves_like 'HTTP 200 response'
    it_behaves_like 'list of elements renderer'
  end

  describe 'GET is_working' do
    subject { get :is_working }

    it_behaves_like 'HTTP 200 response'
  end

  describe 'GET iva_types' do
    before { InvoicesServiceMock.mock(:iva_types) }

    subject { get :iva_types }

    it_behaves_like 'HTTP 200 response'
    it_behaves_like 'list of elements renderer'

    it 'renders a list of IVA types' do
      subject

      data = JSON.parse(response.body)

      data.each do |iva_type|
        expect(iva_type.deep_symbolize_keys)
          .to match_valid_format(StaticControllerSupport::IVA_TYPE_FORMAT)
      end

      expect(data).to include({
        'id' => StaticResource::IvaTypes::EXEMPT_ID.to_s,
        'name' => 'Exento',
      })

      expect(data).to include({
        'id' => StaticResource::IvaTypes::UNTAXED_ID.to_s,
        'name' => 'No gravado',
      })
    end
  end

  describe 'GET optionals' do
    before { InvoicesServiceMock.mock(:optionals) }

    subject { get :optionals }

    it_behaves_like 'HTTP 200 response'
    it_behaves_like 'list of elements renderer'
  end

  describe 'GET sale_points' do
    subject { get :sale_points }

    context 'when a successful response is returned from the external service' do
      before { InvoicesServiceMock.mock(:sale_points) }

      it_behaves_like 'HTTP 200 response'
      it_behaves_like 'list of elements renderer'

      it 'renders a list of sale points' do
        subject

        data = JSON.parse(response.body)

        data.each do |sale_point|
          expect(sale_point.deep_symbolize_keys)
            .to match_valid_format(StaticControllerSupport::SALE_POINT_FORMAT)
        end
      end

      context 'and sale points were previously requested by entity' do
        before do
          get :sale_points
          WebMock.reset!
        end

        it_behaves_like 'HTTP 200 response'
        it_behaves_like 'list of elements renderer'
      end

      context 'and there are deleted sale points' do
        it 'renders a list sale points without the deleted ones' do
          subject

          expect(JSON.parse(response.body).one?).to be true
        end
      end
    end

    context 'when a response with error is returned from the external service' do
      let!(:sale_points_mock) do
        InvoicesServiceMock.mock(:sale_points_error)
      end

      it_behaves_like 'HTTP 200 response'

      it 'renders an error' do
        subject

        data = JSON.parse(response.body)

        expect(data).not_to be_empty
        expect(data['error']).not_to be_nil
      end

      it 'does not cache response' do
        subject

        remove_request_stub(sale_points_mock)

        expect { get :sale_points }
          .to raise_error(WebMock::NetConnectNotAllowedError)
      end
    end
  end
end
