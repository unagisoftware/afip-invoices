# frozen_string_literal: true

require 'test_helper'
require 'support/services/invoice/finder_support'

describe Invoice::Finder do
  let(:entity) { create(:entity) }

  before do
    Rails.cache.clear

    AfipMock.mock_login
    InvoicesServiceMock.mock(:ws_wsdl)
  end

  describe '#run' do
    shared_examples 'invoice details response' do |response_format|
      it 'returns invoice details' do
        response = subject.run

        expect(response).to match_valid_representer_format(response_format)
        expect(response.iva).not_to be_empty
        expect(response.taxes).not_to be_empty

        response.iva.each do |item|
          expect(item)
            .to match_valid_format(Invoice::FinderSupport::AFIP_IVA_FORMAT)
        end

        response.taxes.each do |item|
          expect(item)
            .to match_valid_format(Invoice::FinderSupport::AFIP_TAX_FORMAT)
        end
      end
    end

    context 'when an internal id is received' do
      let(:invoice) { create(:invoice, entity: entity) }

      subject { described_class.new(invoice: invoice, entity: entity) }

      context 'and invoice is for services' do
        before { InvoicesServiceMock.mock(:invoice) }

        it_behaves_like 'invoice details response',
          Invoice::FinderSupport::AFIP_SERVICE_INVOICE_FORMAT
      end

      context 'and invoice is for products' do
        before { InvoicesServiceMock.mock(:product_invoice) }

        it_behaves_like 'invoice details response',
          Invoice::FinderSupport::AFIP_PRODUCT_INVOICE_FORMAT
      end
    end

    context 'when AFIP data is received' do
      let(:params) do
        { bill_number: '10', bill_type_id: '11', sale_point_id: '1' }
      end

      before { InvoicesServiceMock.mock(:invoice) }

      subject { described_class.new(params: params, entity: entity) }

      it_behaves_like 'invoice details response',
        Invoice::FinderSupport::AFIP_SERVICE_INVOICE_FORMAT
    end

    context 'when a previous call is requested' do
      let(:invoice) { create(:invoice, entity: entity) }
      let!(:invoice_mock) { InvoicesServiceMock.mock(:invoice) }

      before { described_class.new(invoice: invoice, entity: entity).run }

      subject { described_class.new(invoice: invoice, entity: entity) }

      it 'returns a cached version of the invoice' do
        remove_request_stub(invoice_mock)
        subject.run
      end
    end

    context 'when a response with error is returned from the external service' do
      let!(:invoice_mock) do
        InvoicesServiceMock.mock(:invoice_not_found)
      end

      let(:invoice) { create(:invoice, entity: entity) }

      before do
        described_class.new(invoice: invoice, entity: entity)
      end

      subject { described_class.new(invoice: invoice, entity: entity) }

      it 'returns nil' do
        expect(subject.run).to be_nil
      end

      it 'does not cache response' do
        remove_request_stub(invoice_mock)

        expect { subject.run }
          .to raise_error(WebMock::NetConnectNotAllowedError)
      end
    end
  end
end
