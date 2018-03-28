# frozen_string_literal: true

require_relative './generator_support'

class Invoice
  class ValidatorSupport
    QUERY = Invoice::GeneratorSupport::PARAMS.deep_dup

    ASSOCIATED_INVOICE = {
      bill_type_id: '11',
      sale_point_id: '0001',
      number: '7',
      date: Date.yesterday.strftime(Invoice::Schema::DATE_FORMAT),
    }.freeze

    DATE_ATTRIBUTES = %i[
      created_at
      due_date
      service_from
      service_to
    ].freeze

    AMOUNT_ATTRIBUTES = %i[
      exempt_amount
      iva_amount
      net_amount
      tax_amount
      total_amount
      untaxed_amount
    ].freeze

    OPT_ATTRIBUTES = {
      alias: '7894561235',
      cbu: '0140590940090418135201',
      transmission: 'SCA',
    }.freeze

    DATE_FORMATS = [
      '%Y/%m/%d',
      '%Y-%m-%d',
      '%Y/%m/%d',
      '%y/%m/%d',
      '%y-%m-%d',
      '%y/%m/%d',
      '%d/%m/%Y',
      '%d-%m-%Y',
      '%d/%m/%Y',
      '%d/%m/%y',
      '%d-%m-%y',
      '%d/%m/%y',
      '%d%m%y',
      '%d%m%Y',
      '%y%m%d',
    ].freeze
  end
end
