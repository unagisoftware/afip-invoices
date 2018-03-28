# frozen_string_literal: true

class InvoiceWithDetailsRepresenter < OpenStruct
  include Representable::JSON

  DATETIME_FORMAT = '%Y%m%d%H%M%S'

  property :authorization_code
  property :bill_number
  property :bill_type_id
  property :concept_type_id
  property :created_at
  property :currency_id
  property :due_date
  property :emission_type
  property :exempt_amount
  property :expiracy_date
  property :items
  property :iva
  property :iva_amount
  property :net_amount
  property :quotation
  property :recipient_number
  property :recipient_type_id
  property :sale_point_id
  property :service_from
  property :service_to
  property :tax_amount
  property :taxes
  property :total_amount
  property :untaxed_amount

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def initialize(bill_number:, bill_type_id:, data:, items:, sale_point_id:)
    super()

    self.authorization_code = data[:cod_autorizacion]
    self.bill_number = bill_number.to_s
    self.bill_type_id = bill_type_id.to_s
    self.concept_type_id = data[:concepto]
    self.created_at = format_datetime(data[:fch_proceso])
    self.currency_id = data[:mon_id]
    self.due_date = format_date(data[:fch_vto_pago])
    self.emission_type = data[:emision_tipo]
    self.exempt_amount = data[:imp_op_ex]
    self.expiracy_date = format_date(data[:fch_vto])
    self.items = items || []
    self.iva = format_iva(data[:iva])
    self.iva_amount = data[:imp_iva]
    self.net_amount = data[:imp_neto]
    self.quotation = data[:mon_cotiz]
    self.recipient_number = data[:doc_nro]
    self.recipient_type_id = data[:doc_tipo]
    self.sale_point_id = sale_point_id
    self.service_from = format_date(data[:fch_serv_desde])
    self.service_to = format_date(data[:fch_serv_hasta])
    self.tax_amount = data[:imp_trib]
    self.taxes = format_taxes(data[:tributos])
    self.total_amount = data[:imp_total]
    self.untaxed_amount = data[:imp_tot_conc]
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  private

  def format_date(date)
    return if date.blank?

    Date
      .parse(date, Invoice::Schema::DATE_FORMAT)
      .strftime('%d/%m/%Y')
  end

  def format_datetime(datetime)
    DateTime
      .parse(datetime, DATETIME_FORMAT)
      .strftime('%d/%m/%Y %H:%M:%S')
  end

  def format_iva(iva)
    return unless iva && iva[:alic_iva]

    Array.wrap(iva[:alic_iva]).map do |item|
      {
        id: item[:id].to_i,
        net_amount: item[:base_imp].to_f,
        total_amount: item[:importe].to_f,
      }
    end
  end

  def format_taxes(taxes)
    return unless taxes && taxes[:tributo]

    Array.wrap(taxes[:tributo]).map do |item|
      {
        id: item[:id].to_i,
        description: item[:desc] || '-',
        rate: item[:alic].to_f,
        net_amount: item[:base_imp].to_f,
        total_amount: item[:importe].to_f,
      }
    end
  end
end
