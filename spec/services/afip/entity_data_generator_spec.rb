# frozen_string_literal: true

require 'test_helper'
require 'support/services/afip/entity_data_generator_support'

describe Afip::EntityDataGenerator do
  let!(:entity) { create(:entity) }

  before do
    RSpec::Mocks.space.proxy_for(described_class).reset
  end

  subject { described_class.new(entity) }

  describe '#call' do
    it 'returns valid data for generating entities' do
      expect(subject.call)
        .to match_valid_format(Afip::EntityDataGeneratorSupport::RESPONSE_FORMAT)
    end
  end
end
