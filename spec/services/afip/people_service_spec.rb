# frozen_string_literal: true

require 'test_helper'
require 'shared_examples/shared_examples_for_afip'

describe Afip::PeopleService do
  let(:entity) { create(:entity) }

  subject { described_class.new(entity) }

  describe '#call' do
    let!(:afip_mocks) do
      [
        PeopleServiceMock.mock(:login_wsdl),
        PeopleServiceMock.mock(:login),
        PeopleServiceMock.mock(:ws_wsdl),
        PeopleServiceMock.mock(:natural_responsible_person),
      ]
    end

    it_behaves_like 'AFIP WS operation execution',
      :get_persona
  end
end
