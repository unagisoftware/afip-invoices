# frozen_string_literal: true

class Afip::PersonSupport
  RESPONSE_FORMAT = {
    address: String,
    category: String,
    city: String,
    full_address: String,
    name: String,
    state: String,
    zipcode: String,
  }.freeze
end
