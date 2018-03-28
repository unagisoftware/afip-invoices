# frozen_string_literal: true

FactoryBot.define do
  factory :associated_invoice do
    association :invoice

    bill_type_id { 11 }
    emission_date { Date.yesterday }
    receipt { "0001-#{Faker::Number.number(digits: 8)}" }
  end
end
