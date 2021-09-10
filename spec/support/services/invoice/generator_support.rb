# frozen_string_literal: true

class Invoice
  class GeneratorSupport
    PARAMS = {
      sale_point_id: '0001',
      concept_type_id: '2',
      recipient_type_id: '8',
      recipient_number: '0001-00000001',
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
          rate: 2.0,
          total_amount: 150,
        },
        {
          id: 2,
          description: 'Another description',
          net_amount: 100,
          rate: 2.0,
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

    CREATED_INVOICE_FORMAT = {
      bill: String,
      bill_number: String,
      cae: String,
      cae_expiracy: String,
      internal_id: Integer,
      render_url: String,
      sale_point_id: String,
      token: String,
    }.freeze

    DEFAULT_INVOICE_FORMAT = {
      bill: NilClass,
      bill_number: NilClass,
      cae: NilClass,
      cae_expiracy: NilClass,
      internal_id: NilClass,
      render_url: NilClass,
      sale_point_id: NilClass,
      token: NilClass,
    }.freeze

    def self.next_bill_number
      data = Hash.from_xml(
        InvoicesServiceMock.mock(:last_bill_number).response.body,
      ).dig(
        'Envelope',
        'Body',
        'FECompUltimoAutorizadoResponse',
        'FECompUltimoAutorizadoResult',
      )

      sale_point = data['PtoVta'].to_i
      number = data['CbteNro'].to_i + 1

      "#{format('%0004d', sale_point)}-#{format('%008d', number)}"
    end
  end
end
