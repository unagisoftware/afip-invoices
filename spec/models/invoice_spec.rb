# frozen_string_literal: true

require 'test_helper'
require 'support/models/invoice_support'

describe Invoice, type: :model do
  describe 'Basics' do
    it 'has a valid factory' do
      expect(build(:invoice)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:entity) }
    it { is_expected.to have_many(:associated_invoices).dependent(:destroy) }
    it { is_expected.to have_many(:items).class_name('InvoiceItem').dependent(:destroy) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:authorization_code) }
    it { is_expected.to validate_presence_of(:bill_type_id) }
    it { is_expected.to validate_presence_of(:emission_date) }
    it { is_expected.to validate_presence_of(:receipt) }
  end

  describe '#qr_code' do
    let!(:invoice_mock) { InvoicesServiceMock.mock(:invoice) }

    before do
      AfipMock.mock_login
      InvoicesServiceMock.mock(:ws_wsdl)
    end

    subject { create(:invoice) }

    it 'fetches information from external service' do
      subject.qr_code

      expect(invoice_mock).to have_been_requested
    end

    it 'returns QR information in JSON format' do
      expect(JSON.parse(subject.qr_code).symbolize_keys)
        .to match_valid_format(InvoiceSupport::QR_FORMAT)
    end
  end

  describe '#fce?' do
    context 'when bill_type_id is an electronic credit invoice id' do
      %w[201 206 211].each do |bill_type_id|
        subject { build(:invoice, bill_type_id: bill_type_id).fce? }

        it { is_expected.to be true }
      end
    end

    context 'when bill_type_id is not an electronic credit invoice id' do
      subject { build(:invoice, bill_type_id: 1).fce? }

      it { is_expected.to be false }
    end
  end

  describe '#note?' do
    context 'when bill_type_id is a note id' do
      %w[2 3 7 8 12 13 52 53].each do |bill_type_id|
        subject { build(:invoice, bill_type_id: bill_type_id).note? }

        it { is_expected.to be true }
      end
    end

    context 'when bill_type_id is an electronic credit note id' do
      %w[202 203 207 208 212 213].each do |bill_type_id|
        subject { build(:invoice, bill_type_id: bill_type_id).note? }

        it { is_expected.to be true }
      end
    end

    context 'when bill_type_id is neither a note id or an electronic credit note id' do
      subject { build(:invoice, bill_type_id: 1).note? }

      it { is_expected.to be false }
    end
  end
end
