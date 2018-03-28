# frozen_string_literal: true

require 'test_helper'
require 'support/services/auth/encryptor_support'

describe Auth::Encryptor do
  before do
    stub_const('Auth::TokenEncryptor::KEY', Auth::EncryptorSupport::KEY)
  end

  it 'encrypt token' do
    expect(described_class.encrypt('my_token')).to be_a_kind_of(String)
  end

  it 'descrypt token' do
    encripted_value = described_class.encrypt('my_token')
    expect(described_class.decrypt(encripted_value)).to eq('my_token')
  end
end
