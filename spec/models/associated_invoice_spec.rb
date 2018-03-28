# frozen_string_literal: true

require 'test_helper'

describe AssociatedInvoice, type: :model do
  describe 'Basics' do
    it 'has a valid factory' do
      expect(build(:associated_invoice)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:invoice) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:bill_type_id) }
    it { is_expected.to validate_presence_of(:emission_date) }
    it { is_expected.to validate_presence_of(:receipt) }
  end
end
