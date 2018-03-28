# frozen_string_literal: true

require_relative './generator_support'
require_relative './validator_support'

class Invoice
  class BuilderSupport
    PARAMS = Invoice::GeneratorSupport::PARAMS
      .merge(bill_number: Faker::Number.number(digits: 2))
      .deep_dup
      .freeze

    ASSOCIATED_INVOICE = Invoice::ValidatorSupport::ASSOCIATED_INVOICE
      .dup
      .freeze
  end
end
