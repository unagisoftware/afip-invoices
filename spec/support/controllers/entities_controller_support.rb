# frozen_string_literal: true

class EntitiesControllerSupport
  ENTITY_SHORT_FORMAT = {
    business_name: String,
    csr: [NilClass, String],
    cuit: String,
    id: Integer,
    logo_url: [NilClass, String],
    name: String,
  }.freeze

  ENTITY_LONG_FORMAT = {
    auth_token: String,
    business_name: String,
    completed: [TrueClass, FalseClass],
    created_at: String,
    cuit: String,
    id: Integer,
    name: String,
  }.freeze
end
