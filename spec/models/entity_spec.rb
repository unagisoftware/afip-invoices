# frozen_string_literal: true

require 'test_helper'
require 'support/models/entity_support'

describe Entity, type: :model do
  describe 'Basics' do
    it 'has a valid factory' do
      expect(build(:entity)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:invoices).dependent(:destroy) }
  end

  describe 'Validations' do
    context 'presence validations' do
      it { is_expected.to validate_presence_of(:business_name) }
      it { is_expected.to validate_presence_of(:cuit) }
      it { is_expected.to validate_presence_of(:name) }
    end

    context 'uniqueness validations' do
      subject { create(:entity) }

      it { is_expected.to validate_uniqueness_of(:business_name) }
      it { is_expected.to validate_uniqueness_of(:cuit).case_insensitive }
    end
  end

  describe '#as_json' do
    subject { create(:entity) }

    it 'returns a representation as JSON' do
      expect(subject.as_json.symbolize_keys)
        .to match_valid_format(EntitySupport::JSON_FORMAT)
    end
  end
end
