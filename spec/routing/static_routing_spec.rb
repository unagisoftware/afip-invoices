require 'test_helper'

describe 'routes for Static' do
  describe 'without version' do
    it 'routes GET /bill_types to bill_types' do
      expect(get('/bill_types')).to route_to('v1/static#bill_types')
    end

    it 'routes GET /concept_types to concept_types' do
      expect(get('/concept_types')).to route_to('v1/static#concept_types')
    end

    it 'routes GET /currencies to currencies' do
      expect(get('/currencies')).to route_to('v1/static#currencies')
    end

    it 'routes GET /document_types to document_types' do
      expect(get('/document_types')).to route_to('v1/static#document_types')
    end

    it 'routes GET /iva_types to iva_types' do
      expect(get('/iva_types')).to route_to('v1/static#iva_types')
    end

    it 'routes GET /sale_points to sale_points' do
      expect(get('/sale_points')).to route_to('v1/static#sale_points')
    end

    it 'routes GET /tax_types to tax_types' do
      expect(get('/tax_types')).to route_to('v1/static#tax_types')
    end

    it 'routes GET /optionals to optionals' do
      expect(get('/optionals')).to route_to('v1/static#optionals')
    end

    it 'routes GET /dummy to dummy' do
      expect(get('/dummy')).to route_to('v1/static#is_working')
    end
  end

  describe 'v1' do
    it 'routes GET /v1/bill_types to bill_types' do
      expect(get('/v1/bill_types')).to route_to('v1/static#bill_types')
    end

    it 'routes GET /v1/concept_types to concept_types' do
      expect(get('/v1/concept_types')).to route_to('v1/static#concept_types')
    end

    it 'routes GET /v1/currencies to currencies' do
      expect(get('/v1/currencies')).to route_to('v1/static#currencies')
    end

    it 'routes GET /v1/document_types to document_types' do
      expect(get('/v1/document_types')).to route_to('v1/static#document_types')
    end

    it 'routes GET /v1/iva_types to iva_types' do
      expect(get('/v1/iva_types')).to route_to('v1/static#iva_types')
    end

    it 'routes GET /v1/sale_points to sale_points' do
      expect(get('/v1/sale_points')).to route_to('v1/static#sale_points')
    end

    it 'routes GET /v1/tax_types to tax_types' do
      expect(get('/v1/tax_types')).to route_to('v1/static#tax_types')
    end

    it 'routes GET /v1/optionals to optionals' do
      expect(get('/v1/optionals')).to route_to('v1/static#optionals')
    end

    it 'routes GET /v1/dummy to dummy' do
      expect(get('/v1/dummy')).to route_to('v1/static#is_working')
    end
  end
end
