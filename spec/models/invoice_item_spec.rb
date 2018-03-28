# frozen_string_literal: true

require 'test_helper'

describe InvoiceItem, type: :model do
  describe 'Basics' do
    it 'has a valid factory' do
      expect(build(:invoice_item)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:invoice) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:bonus_percentage) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:unit_price) }
  end

  describe '#exempt?' do
    context 'when iva_aliquot_id is 98 (exempt)' do
      subject { build(:invoice_item, iva_aliquot_id: 98).exempt? }

      it { is_expected.to be true }
    end

    context 'when iva_aliquot_id is not 98 (exempt)' do
      subject { build(:invoice_item, iva_aliquot_id: 1).exempt? }

      it { is_expected.to be false }
    end
  end

  describe '#untaxed?' do
    context 'when iva_aliquot_id is 99 (untaxed)' do
      subject { build(:invoice_item, iva_aliquot_id: 99).untaxed? }

      it { is_expected.to be true }
    end

    context 'when iva_aliquot_id is not 99 (untaxed)' do
      subject { build(:invoice_item, iva_aliquot_id: 1).untaxed? }

      it { is_expected.to be false }
    end
  end

  describe '#iva_aliquot' do
    before do
      Rails.cache.clear
      AfipMock.mock_login
      InvoicesServiceMock.mock(:ws_wsdl)
      InvoicesServiceMock.mock(:iva_types)
    end

    context 'when iva_aliquot_id id 4' do
      subject { build(:invoice_item, iva_aliquot_id: 4).iva_aliquot }

      it { is_expected.to eq(10.5) }
    end

    context 'when iva_aliquot_id id 5' do
      subject { build(:invoice_item, iva_aliquot_id: 5).iva_aliquot }

      it { is_expected.to eq(21) }
    end

    context 'when iva_aliquot_id id 6' do
      subject { build(:invoice_item, iva_aliquot_id: 6).iva_aliquot }

      it { is_expected.to eq(27) }
    end

    context 'when iva_aliquot_id id 98 (exempt)' do
      subject { build(:invoice_item, iva_aliquot_id: 98).iva_aliquot }

      it { is_expected.to eq(0) }
    end

    context 'when iva_aliquot_id id 99 (untaxed)' do
      subject { build(:invoice_item, iva_aliquot_id: 99).iva_aliquot }

      it { is_expected.to eq(0) }
    end
  end

  describe '#total' do
    subject do
      create(
        :invoice_item,
        quantity: 7,
        unit_price: 100,
        bonus_percentage: bonus_percentage,
      )
    end

    context 'when bonus percentage is zero' do
      let(:bonus_percentage) { 0 }

      it 'calculates total' do
        expect(subject.total).to eq(700)
      end
    end

    context 'when bonus percentage is greater than zero' do
      let(:bonus_percentage) { 17 }

      it 'calculates total applying the bonus percentage' do
        expect(subject.total).to eq(581)
      end
    end
  end

  describe '#bonus_amount' do
    subject do
      create(
        :invoice_item,
        quantity: 7,
        unit_price: 100,
        bonus_percentage: bonus_percentage,
      )
    end

    context 'when bonus percentage is zero' do
      let(:bonus_percentage) { 0 }

      it 'calculates bonus amount as zero' do
        expect(subject.bonus_amount).to eq(0)
      end
    end

    context 'when bonus percentage is greater than zero' do
      let(:bonus_percentage) { 17 }

      it 'calculates bonus amount applying the bonus percentage' do
        expect(subject.bonus_amount).to eq(119)
      end
    end
  end
end
