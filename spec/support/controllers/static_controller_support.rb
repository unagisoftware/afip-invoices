# frozen_string_literal: true

class StaticControllerSupport
  SALE_POINT_FORMAT = {
    enabled: [TrueClass, FalseClass],
    id: String,
    name: String,
    type: String,
  }.freeze

  IVA_TYPE_FORMAT = {
    id: String,
    name: String,
  }.freeze
end
