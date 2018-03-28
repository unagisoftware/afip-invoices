# frozen_string_literal: true

require 'test_helper'
require 'shared_examples/shared_examples_for_controllers'
require 'support/controllers/invoices_controller_support'

describe V1::InvoicesController, type: :controller do
  shared_examples 'invoice not found response' do
    it_behaves_like 'HTTP 404 response'

    it 'renders an error' do
      subject

      expect(JSON.parse(response.body)['error'])
        .to eq('Recurso no encontrado')
    end
  end

  let(:entity) { create(:entity) }

  before do
    AfipMock.mock_login

    InvoicesServiceMock.mock(:ws_wsdl)
    PeopleServiceMock.mock(:ws_wsdl)

    request.headers['HTTP_AUTHORIZATION'] = "Token token=\"#{entity.auth_token}\""
  end

  describe 'GET index' do
    before do
      create_list(:invoice, 2, entity: entity)
    end

    subject { get :index }

    it_behaves_like 'HTTP 200 response'

    it 'renders a list of invoices' do
      subject

      expect(JSON.parse(response.body)).not_to be_empty
    end
  end

  describe 'GET details' do
    let(:invoice) { create(:invoice) }
    let!(:invoice_mock) { InvoicesServiceMock.mock(:invoice) }
    let(:params) do
      {
        id: invoice.token,
        bill_type_id: '11',
        bill_number: '10',
        sale_point_id: '1',
      }
    end

    subject { get :details, params: params }

    it_behaves_like 'HTTP 200 response'

    it 'connects with external service to fetch invoice information' do
      subject

      expect(invoice_mock).to have_been_requested
    end

    it 'renders invoice details' do
      subject

      data = JSON.parse(response.body).deep_symbolize_keys

      expect(data)
        .to match_valid_format(InvoicesControllerSupport::DETAILS_RESPONSE_FORMAT)

      ['bill_type_id', 'bill_number', 'sale_point_id'].each do |attr|
        expect(data[attr]).to eq(params[attr])
      end
    end
  end

  describe 'GET show' do
    context 'when a valid invoice token is received' do
      let(:invoice) { create(:invoice) }
      let!(:invoice_mock) { InvoicesServiceMock.mock(:invoice) }

      subject { get :show, params: { id: invoice.token } }

      it_behaves_like 'HTTP 200 response'

      it 'connects with external service to fetch invoice information' do
        subject

        expect(invoice_mock).to have_been_requested
      end

      it 'renders invoice details' do
        subject

        data = JSON.parse(response.body).deep_symbolize_keys

        expect(data)
          .to match_valid_format(InvoicesControllerSupport::DETAILS_RESPONSE_FORMAT)
      end
    end

    context 'when an invalid invoice token is received' do
      subject { get :show, params: { id: SecureRandom.uuid } }

      it_behaves_like 'invoice not found response'
    end
  end

  describe 'POST create' do
    shared_examples 'invoice response' do
      it 'renders invoice details' do
        subject

        data = JSON.parse(response.body).deep_symbolize_keys

        expect(data)
          .to match_valid_format(InvoicesControllerSupport::CREATE_RESPONSE_FORMAT_RESPONSE)
      end
    end

    shared_examples 'errors response' do |errors_key|
      it 'renders errors response' do
        subject

        data = JSON.parse(response.body).deep_symbolize_keys

        expect(data)
          .to match_valid_format(InvoicesControllerSupport::ERROR_RESPONSE_FORMAT)

        expect(data[errors_key]).not_to be_empty
      end
    end

    before do
      InvoicesServiceMock.mock(:last_bill_number)
      InvoicesServiceMock.mock(:create_invoice)
      PeopleServiceMock.mock(:legal_person)
    end

    context 'when parameters are correct' do
      subject do
        post :create,
          params: InvoicesControllerSupport::INVOICE_PARAMS,
          as: :json
      end

      context 'and invoice is not persisted' do
        it_behaves_like 'invoice response'
        it_behaves_like 'HTTP 201 response'

        it 'creates an invoice and its items' do
          expect { subject }
            .to change  { Invoice.count }.by(1)
            .and change { InvoiceItem.count }
            .by(InvoicesControllerSupport::INVOICE_PARAMS[:items].size)

          invoice = Invoice.last

          expect(invoice.items.size)
            .to eq(InvoicesControllerSupport::INVOICE_PARAMS[:items].size)

          expect(invoice.recipient).not_to be_nil

          expect(invoice.recipient.symbolize_keys)
            .to match_valid_format(InvoicesControllerSupport::RECIPIENT_FORMAT)

          attributes = InvoicesControllerSupport::INVOICE_PARAMS[:items].first.keys

          invoice.items.each.with_index do |item, index|
            expect(item.attributes.symbolize_keys.slice(*attributes))
              .to eq(InvoicesControllerSupport::INVOICE_PARAMS[:items][index])
          end
        end
      end

      context 'and invoice already exists' do
        let!(:invoice) do
          create(
            :invoice,
            bill_type_id: InvoicesControllerSupport::INVOICE_PARAMS[:bill_type_id],
            receipt: InvoicesControllerSupport::INVOICE_PARAMS[:recipient_number],
          )
        end

        it_behaves_like 'invoice response'
        it_behaves_like 'HTTP 200 response'
      end

      context 'and AFIP invoice generation fails' do
        before do
          expect_any_instance_of(Afip::Manager)
            .to receive(:request_invoice)
            .and_return({ response: {} })
        end

        it_behaves_like 'HTTP 100 response'
      end
    end

    context 'when parameters are incorrect' do
      subject do
        post :create,
          params: InvoicesControllerSupport::INVOICE_PARAMS.except(:sale_point_id),
          as: :json
      end

      it_behaves_like 'errors response', :errors
      it_behaves_like 'HTTP 400 response'
    end

    context 'when a response with error is returned from the external service' do
      before do
        InvoicesServiceMock.mock(:create_invoice_error)
      end

      subject do
        post :create,
          params: InvoicesControllerSupport::INVOICE_PARAMS,
          as: :json
      end

      it_behaves_like 'errors response', :afip_errors
      it_behaves_like 'HTTP 400 response'
    end
  end

  describe 'GET export' do
    context 'when a valid invoice token is received' do
      let(:invoice) { create(:invoice) }

      let!(:afip_mocks) do
        [
          InvoicesServiceMock.mock(:bill_types),
          InvoicesServiceMock.mock(:iva_types),
          InvoicesServiceMock.mock(:tax_types),
          InvoicesServiceMock.mock(:invoice),
          PeopleServiceMock.mock(:natural_responsible_person),
        ]
      end

      before do
        create_list(:invoice_item, 2, invoice: invoice)

        AfipMock.mock_login
        InvoicesServiceMock.mock(:ws_wsdl)
        PeopleServiceMock.mock(:ws_wsdl)
      end

      subject do
        get :export, params: { id: invoice.token }, format: :pdf
      end

      it_behaves_like 'HTTP 200 response'
      it_behaves_like 'PDF response'

      it 'fetches invoice information from external service' do
        subject

        afip_mocks.each { |mock| expect(mock).to have_been_requested }
      end
    end

    context 'when an invalid invoice token is received' do
      subject do
        get :export, params: { id: SecureRandom.uuid }, format: :pdf
      end

      it_behaves_like 'invoice not found response'
    end
  end

  describe 'POST export_preview' do
    let!(:afip_mocks) do
      [
        InvoicesServiceMock.mock(:bill_types),
        InvoicesServiceMock.mock(:iva_types),
        InvoicesServiceMock.mock(:tax_types),
        PeopleServiceMock.mock(:natural_responsible_person),
      ]
    end

    before do
      AfipMock.mock(:login_wsdl)
      AfipMock.mock(:login)
      InvoicesServiceMock.mock(:ws_wsdl)
      PeopleServiceMock.mock(:ws_wsdl)
    end

    subject do
      post :export_preview,
        params: InvoicesControllerSupport::INVOICE_PARAMS.merge(bill_number: 7),
        format: :pdf
    end

    it_behaves_like 'HTTP 200 response'
    it_behaves_like 'PDF response'

    it 'fetches invoice information from external service' do
      subject

      afip_mocks.each { |mock| expect(mock).to have_been_requested }
    end
  end
end
