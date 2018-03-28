# frozen_string_literal: true

require 'test_helper'

describe AfipRequest, type: :model do
  describe 'Basics' do
    it 'has a valid factory' do
      expect(build(:afip_request)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:entity) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:bill_number) }
    it { is_expected.to validate_presence_of(:bill_type_id) }
    it { is_expected.to validate_presence_of(:invoice_id_client) }
    it { is_expected.to validate_presence_of(:sale_point_id) }
  end
end
