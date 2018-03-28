# frozen_string_literal: true

require 'test_helper'
require 'support/services/auth/encryptor_support'

describe Auth::TokenValidator do
  before do
    stub_const('Auth::TokenEncryptor::KEY', Auth::EncryptorSupport::KEY)
  end

  describe '#call' do
    let!(:entity) { create(:entity) }

    context 'when token is valid' do
      subject { described_class.new(entity.auth_token) }

      it 'returns the associated entity' do
        expect(subject.call).to eq(entity)
        expect(Rails.cache.read(entity.auth_token)).to eq(entity)
      end
    end

    context 'when token is invalid' do
      subject { described_class.new('invalid_token') }

      it 'returns nil' do
        expect(subject.call).to be_nil
      end
    end
  end
end
