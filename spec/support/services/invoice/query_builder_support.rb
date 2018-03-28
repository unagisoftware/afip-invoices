# frozen_string_literal: true

require_relative './generator_support'
require_relative './validator_support'

class Invoice
  class QueryBuilderSupport
    RESPONSE_MASTER_KEY = 'FeCAEReq'
    RESPONSE_HEADER_KEY = 'FeCabReq'
    RESPONSE_BODY_KEY = 'FeDetReq'
    RESPONSE_BODY_CONTENT_KEY = 'FECAEDetRequest'

    RESPONSE_FORMAT = {
      RESPONSE_BODY_KEY => Hash,
      RESPONSE_HEADER_KEY => Hash,
    }.freeze

    RESPONSE_HEADER_FORMAT = {
      'CantReg' => Integer,
      'CbteTipo' => String,
      'PtoVta' => String,
    }.freeze

    RESPONSE_BODY_FORMAT = {
      RESPONSE_BODY_CONTENT_KEY => Hash,
    }.freeze

    IVA_CONTENT_KEY = 'AlicIva'
    IVA_KEY = 'Iva'
    TAXES_KEY = 'Tributos'
    TAXES_CONTENT_KEY = 'Tributo'
    OPT_KEY = 'Opcionales'
    OPT_CONTENT_KEY = 'Opcional'

    RESPONSE_BODY_CONTENT_FORMAT = {
      'CbteDesde' => Integer,
      'CbteFch' => String,
      'CbteHasta' => Integer,
      'Concepto' => String,
      'DocNro' => String,
      'DocTipo' => String,
      'FchServDesde' => String,
      'FchServHasta' => String,
      'FchVtoPago' => String,
      'ImpIVA' => Float,
      'ImpNeto' => Float,
      'ImpOpEx' => Float,
      'ImpTotConc' => Float,
      'ImpTotal' => Float,
      'ImpTrib' => Float,
      'MonCotiz' => Integer,
      'MonId' => String,
      IVA_KEY  => Hash,
      TAXES_KEY => Hash,
    }.freeze

    IVA_CONTENT_FORMAT = {
      'BaseImp' => Float,
      'Id' => String,
      'Importe' => Float,
    }.freeze

    TAXES_CONTENT_FORMAT = {
      'Alic' => Float,
      'BaseImp' => Float,
      'Desc' => String,
      'Id' => String,
      'Importe' => Float,
    }.freeze

    OPT_CONTENT_FORMAT = {
      'Id' => String,
      'Valor' => String,
    }.freeze

    QUERY = Invoice::GeneratorSupport::PARAMS.deep_dup.merge(
      bill_number: 10,
      cuit: Faker::Number.number(digits: 10),
    ).freeze

    ASSOCIATED_INVOICE = Invoice::ValidatorSupport::ASSOCIATED_INVOICE.dup.freeze

    OPT_ATTRIBUTES = Invoice::ValidatorSupport::OPT_ATTRIBUTES.dup.freeze
  end
end
