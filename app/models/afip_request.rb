# frozen_string_literal: true

class AfipRequest < ApplicationRecord
  validates :bill_number, presence: true
  validates :bill_type_id, presence: true
  validates :invoice_id_client, presence: true
  validates :sale_point_id, presence: true

  belongs_to :entity
end
