require 'test_helper'

describe 'routes for Entities' do
  describe 'without version' do
    let(:prefix_url) { '/entities' }

    it 'routes GET /entities to index' do
      expect(get(prefix_url)).to route_to('v1/entities#index')
    end

    it 'routes POST /entities to create' do
      expect(post(prefix_url)).to route_to('v1/entities#create')
    end

    it 'routes GET /entities/:id to show' do
      expect(get("#{prefix_url}/1")).to route_to(controller: 'v1/entities', action: 'show', id: '1')
    end

    it 'routes PUT/PATCH /entities/:id to update' do
      expect(patch("#{prefix_url}/1")).to route_to(controller: 'v1/entities', action: 'update', id: '1')
      expect(put("#{prefix_url}/1")).to route_to(controller: 'v1/entities', action: 'update', id: '1')
    end
  end

  describe 'v1' do
    let(:prefix_url) { '/v1/entities' }

    it 'routes GET /v1/entities to index' do
      expect(get(prefix_url)).to route_to('v1/entities#index')
    end

    it 'routes POST /v1/entities to create' do
      expect(post(prefix_url)).to route_to('v1/entities#create')
    end

    it 'routes GET /v1/entities/:id to show' do
      expect(get("#{prefix_url}/1")).to route_to(controller: 'v1/entities', action: 'show', id: '1')
    end

    it 'routes PUT/PATCH /v1/entities to update' do
      expect(patch("#{prefix_url}/1")).to route_to(controller: 'v1/entities', action: 'update', id: '1')
      expect(put("#{prefix_url}/1")).to route_to(controller: 'v1/entities', action: 'update', id: '1')
    end
  end
end
