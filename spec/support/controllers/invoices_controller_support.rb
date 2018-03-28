# frozen_string_literal: true

class InvoicesControllerSupport
  DETAILS_RESPONSE_FORMAT = {
    authorization_code: String,
    bill_number: String,
    bill_type_id: String,
    concept_type_id: String,
    created_at: String,
    currency_id: String,
    due_date: String,
    emission_type: String,
    exempt_amount: String,
    expiracy_date: String,
    items: Array,
    iva: Array,
    iva_amount: String,
    net_amount: String,
    quotation: String,
    recipient_number: String,
    recipient_type_id: String,
    sale_point_id: String,
    service_from: String,
    service_to: String,
    tax_amount: String,
    taxes: Array,
    total_amount: String,
    untaxed_amount: String,
  }.freeze

  INVOICE_PARAMS = {
    external_id: '1',
    sale_point_id: '0001',
    concept_type_id: '2',
    recipient_type_id: '8',
    recipient_number: '20376793126',
    net_amount: 2000,
    iva_amount: 250,
    untaxed_amount: 1800,
    exempt_amount: 300,
    tax_amount: 250,
    iva: [
      {
        id: 1,
        net_amount: 1500,
        total_amount: 150,
      },
      {
        id: 2,
        net_amount: 500,
        total_amount: 100,
      },
    ],
    taxes: [
      {
        id: 1,
        description: 'Some description',
        net_amount: 150,
        total_amount: 150,
      },
      {
        id: 2,
        description: 'Another description',
        net_amount: 100,
        total_amount: 100,
      },
    ],
    bill_type_id: '11',
    created_at: Date.today.strftime(Invoice::Schema::DATE_FORMAT),
    total_amount: 4600,
    service_from: 1.month.ago.strftime(Invoice::Schema::DATE_FORMAT),
    service_to: 1.day.ago.strftime(Invoice::Schema::DATE_FORMAT),
    due_date: Date.today.strftime(Invoice::Schema::DATE_FORMAT),
    associated_invoices: [],
    items: [
      {
        description: 'Servicios de Informática',
        quantity: 10,
        unit_price: 150.5,
        metric_unit: 'horas',
        iva_aliquot_id: 5, # 21%
        bonus_percentage: 0,
      },
      {
        description: 'Servicios de hosting',
        quantity: 1,
        unit_price: 550,
        metric_unit: 'unidades',
        iva_aliquot_id: 4, # 10.5%
        bonus_percentage: 10,
      },
      {
        description: 'No gravado',
        quantity: 2,
        unit_price: 1000,
        metric_unit: 'unidades',
        iva_aliquot_id: StaticResource::IvaTypes::UNTAXED_ID,
        bonus_percentage: 10,
      },
      {
        description: 'Exento',
        quantity: 1,
        unit_price: 300,
        metric_unit: 'unidades',
        iva_aliquot_id: StaticResource::IvaTypes::EXEMPT_ID,
        bonus_percentage: 0,
      },
    ],
  }.freeze

  CREATE_RESPONSE_FORMAT_RESPONSE = {
    bill: String,
    bill_number: String,
    cae: String,
    cae_expiracy: String,
    internal_id: Integer,
    render_url: String,
    sale_point_id: String,
    token: String,
  }.freeze

  ERROR_RESPONSE_FORMAT = {
    errors: Array,
    afip_errors: Array,
  }.freeze

  RECIPIENT_FORMAT = {
    address: String,
    category: String,
    city: String,
    full_address: String,
    name: String,
    state: String,
    zipcode: String,
  }.freeze

end
