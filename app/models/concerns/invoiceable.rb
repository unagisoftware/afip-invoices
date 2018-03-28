# frozen_string_literal: true

require 'active_support/concern'

module Invoiceable
  extend ActiveSupport::Concern

  included do
    validates :bill_type_id, presence: true
    validates :emission_date, presence: true
    validates :receipt, presence: true

    def sale_point_id
      receipt.split('-').first
    end

    def bill_number
      receipt.split('-').last
    end
  end
end
