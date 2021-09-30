# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    association :entity

    authorization_code { Faker::Number.number(digits: 10) }
    bill_type_id { 11 }
    emission_date { Date.yesterday }
    receipt { "0001-#{Faker::Number.number(digits: 8)}" }
    token { SecureRandom.hex(10) }

    factory :note do
      bill_type_id { 2 }
    end

    factory :electronic_credit_invoice do
      bill_type_id { 201 }
    end

    factory :electronic_note do
      bill_type_id { 202 }
    end
  end
end
