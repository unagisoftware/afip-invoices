# frozen_string_literal: true

class Invoice
  class Schema
    CONCEPTS = {
      products: 1,
      services: 2,
      products_and_services: 3,
    }.freeze

    REQUIRED_ATTRIBUTES = {
      sale_point_id: 'Punto de venta',
      concept_type_id: 'Tipo de concepto',
      recipient_type_id: 'Tipo de documento de comprador',
      recipient_number: 'Número de identificación de comprador',
      bill_type_id: 'Tipo de comprobante',
      net_amount: 'Importe neto gravado',
      untaxed_amount: 'Importe neto no gravado',
      exempt_amount: 'Importe exento',
      iva_amount: 'Importe total de IVA',
      tax_amount: 'Importe total de tributos',
      total_amount: 'Importe total',
    }.freeze

    NUMERIC_ATTRIBUTES = REQUIRED_ATTRIBUTES.slice(
      :net_amount,
      :untaxed_amount,
      :exempt_amount,
      :iva_amount,
      :tax_amount,
      :total_amount,
    ).freeze

    ITEM_REQUIRED_ATTRIBUTES = {
      description: 'Descripción',
      unit_price: 'Precio unitario',
      iva_aliquot_id: 'Alícuota de IVA',
    }.freeze

    ITEM_NUMERIC_ATTRIBUTES = {
      quantity: 'Cantidad',
      unit_price: 'Precio unitario',
      bonus_percentage: 'Porcentaje de bonificación',
      iva_aliquot_id: 'Alícuota de IVA',
    }.freeze

    ASSOCIATED_INVOICE_ATTRIBUTES = {
      bill_type_id: 'Tipo de comprobante',
      sale_point_id: 'Punto de venta',
      number: 'Número de comprobante',
      date: 'Fecha del comprobante',
    }.freeze

    DATE_REGEX  = /^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$/.freeze
    DATE_FORMAT = '%Y%m%d'
    FLOAT_REGEX = /^[0-9]*\.?[0-9]+$/.freeze

    ELECTRONIC_CREDIT_INVOICES_IDS = %w[201 206 211].freeze
    ELECTRONIC_NOTES_IDS = %w[202 203 207 208 212 213].freeze
    NOTES_IDS = %w[2 3 7 8 12 13 52 53].freeze
  end
end
