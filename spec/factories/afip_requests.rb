# frozen_string_literal: true

FactoryBot.define do
  factory :afip_request do
    association :entity

    bill_number { "0001-#{Faker::Number.number(digits: 8)}" }
    bill_type_id { 11 }
    invoice_id_client { Faker::Number.number(digits: 1) }
    sale_point_id { 1 }
  end
end
