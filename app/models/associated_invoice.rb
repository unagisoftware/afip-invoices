# frozen_string_literal: true

class AssociatedInvoice < ApplicationRecord
  include Invoiceable

  belongs_to :invoice
end
