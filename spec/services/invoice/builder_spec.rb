# frozen_string_literal: true

require 'test_helper'
require 'support/services/invoice/builder_support'

describe Invoice::Builder do
  let(:entity) { create(:entity) }
  let(:params) { Invoice::BuilderSupport::PARAMS }

  before do
    AfipMock.mock_login
    PeopleServiceMock.mock(:ws_wsdl)
  end

  subject { described_class.new(params, entity) }

  describe '#call' do
    let!(:people_mock) do
      PeopleServiceMock.mock(:natural_responsible_person)
    end

    it 'returns a non-persisted invoice instance' do
      invoice = subject.call

      expect(invoice).to be_an_instance_of(Invoice)
      expect(invoice).not_to be_persisted
    end

    it 'builds invoice items' do
      invoice = subject.call

      expect(invoice.items).not_to be_empty
      expect(invoice.items.size).to eq(params[:items].size)

      params[:items].each do |item_data|
        item = invoice.items.find do |record|
          record.description == item_data[:description]
        end

        expect(item).to have_attributes(item_data)
      end
    end

    it 'does not create any invoice' do
      expect { subject.call }.not_to change { Invoice.count }
    end

    it 'fetches person information from external service' do
      subject.call

      expect(people_mock).to have_been_requested
    end

    context 'when invoice has associated invoices' do
      let(:params) do
        Invoice::BuilderSupport::PARAMS.merge(
          associated_invoices: [Invoice::BuilderSupport::ASSOCIATED_INVOICE],
        )
      end

      it 'builds associated invoices' do
        invoice = subject.call

        expect(invoice.associated_invoices).not_to be_empty

        expect(invoice.associated_invoices.size)
          .to eq(params[:associated_invoices].size)
      end
    end

    context 'when no metric unit is provided for each item' do
      before do
        params[:items].each do |item|
          item[:metric_unit] = nil
        end
      end

      it 'builds invoice items with default unit' do
        invoice = subject.call

        expect(invoice.items).not_to be_empty
        expect(invoice.items.size).to eq(params[:items].size)

        invoice.items.each do |item|
          expect(item[:metric_unit]).not_to be_blank
          expect(item[:metric_unit]).to eq(Invoice::Creator::DEFAULT_ITEM_UNIT)
        end
      end
    end
  end
end
