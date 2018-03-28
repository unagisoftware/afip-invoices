require 'test_helper'

describe 'routes for Afip People' do
  let(:cuit) { '111111111111111' }

  describe 'without version' do
    let(:prefix_url) { '/afip_people' }

    it 'routes GET /afip_people to show' do
      expect(get("#{prefix_url}/#{cuit}")).to route_to(controller: 'v1/afip_people', action: 'show', cuit: cuit)
    end
  end

  describe 'v1' do
    let(:prefix_url) { '/v1/afip_people' }

    it 'routes GET /v1/afip_people to show' do
      expect(get("#{prefix_url}/#{cuit}")).to route_to(controller: 'v1/afip_people', action: 'show', cuit: cuit)
    end
  end
end
