# frozen_string_literal: true

class Invoice
  class FinderSupport
    RESPONSE = {
      concept_type_id: '3',
      recipient_type_id: '80',
      recipient_number: '20308769608',
      bill_number: '0001-00000012',
      bill_type_id: '1',
      total_amount: '3170',
      untaxed_amount: '200',
      net_amount: '2000',
      exempt_amount: '300',
      tax_amount: '250',
      iva_amount: '420',
      service_from: '01/03/2018',
      service_to: '31/03/2018',
      due_date: '20/04/2018',
      currency_id: 'PES',
      quotation: '1',
      authorization_code: '68166645934991',
      emission_type: 'CAE',
      expiracy_date: '30/04/2018',
      created_at: '20/04/2018 16:55:58',
      sale_point_id:      3,
      iva: [
        { id:5, net_amount:2000.0, total_amount:420.0 },
      ],
      taxes: [
        { id:1, description:'-', rate:2.0, net_amount:150.0, total_amount:150.0 },
        { id:2, description:'-', rate:2.0, net_amount:100.0, total_amount:100.0 },
      ],
      items: [],
    }.freeze

    AFIP_SERVICE_INVOICE_FORMAT = {
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

    AFIP_PRODUCT_INVOICE_FORMAT = AFIP_SERVICE_INVOICE_FORMAT.merge(
      due_date: NilClass,
      service_from: NilClass,
      service_to: NilClass,
    ).freeze

    AFIP_IVA_FORMAT = {
      id: Integer,
      net_amount: Float,
      total_amount: Float,
    }.freeze

    AFIP_TAX_FORMAT = {
      description: String,
      id: Integer,
      net_amount: Float,
      rate: Float,
      total_amount: Float,
    }.freeze
  end
end
