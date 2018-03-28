require 'test_helper'

describe 'routes for Invoice' do
  describe 'without version' do
    let(:prefix_url) { '/invoices' }

    it 'routes GET /invoices to index' do
      expect(get(prefix_url)).to route_to('v1/invoices#index')
    end

    it 'routes POST /invoices to create' do
      expect(post(prefix_url)).to route_to('v1/invoices#create')
    end

    it 'routes GET /invoices/:id to show' do
      expect(get("#{prefix_url}/1")).to route_to(controller: 'v1/invoices', action: 'show', id: '1')
    end

    it 'routes GET /invoices/details to details' do
      expect(get("#{prefix_url}/details")).to route_to('v1/invoices#details')
    end

    it 'routes GET /invoices/:id/export to export' do
      expect(get("#{prefix_url}/1/export")).to route_to(controller: 'v1/invoices', action: 'export', id: '1')
    end

    it 'routes POST /invoices/export_preview to export_preview' do
      expect(post("#{prefix_url}/export_preview")).to route_to('v1/invoices#export_preview')
    end
  end

  describe 'v1' do
    let(:prefix_url) { '/v1/invoices' }

    it 'routes GET /v1/invoices to index' do
      expect(get(prefix_url)).to route_to('v1/invoices#index')
    end

    it 'routes POST /v1/invoices to create' do
      expect(post(prefix_url)).to route_to('v1/invoices#create')
    end

    it 'routes GET /v1/invoices/:id to show' do
      expect(get("#{prefix_url}/1")).to route_to(controller: 'v1/invoices', action: 'show', id: '1')
    end

    it 'routes GET /v1/invoices/details to details' do
      expect(get("#{prefix_url}/details")).to route_to('v1/invoices#details')
    end

    it 'routes GET /v1/invoices/:id/export to export' do
      expect(get("#{prefix_url}/1/export")).to route_to(controller: 'v1/invoices', action: 'export', id: '1')
    end

    it 'routes POST /v1/invoices/export_preview to export_preview' do
      expect(post("#{prefix_url}/export_preview")).to route_to('v1/invoices#export_preview')
    end
  end
end
