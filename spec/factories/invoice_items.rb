# frozen_string_literal: true

FactoryBot.define do
  factory :invoice_item do
    association :invoice

    bonus_percentage { 0 }
    code { Faker::Number.number(digits: 10) }
    description { Faker::Lorem.sentence }
    iva_aliquot_id { 5 }
    metric_unit { 'unidades' }
    quantity { Faker::Number.number(digits: 1) }
    unit_price { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
