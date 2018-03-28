# frozen_string_literal: true

class GeneratedInvoiceRepresenter < OpenStruct
  include Representable::JSON

  delegate :authorization_code, to: :invoice, allow_nil: true
  delegate :bill_number, to: :invoice, allow_nil: true
  delegate :id, to: :invoice, prefix: :internal, allow_nil: true
  delegate :token, to: :invoice, allow_nil: true
  delegate :sale_point_id, to: :invoice, allow_nil: true

  property :bill
  property :bill_number
  property :cae
  property :cae_expiracy
  property :internal_id
  property :render_url
  property :sale_point_id
  property :token

  def initialize(bill:, cae_expiracy:, invoice:)
    super()

    self.bill = bill
    self.cae = invoice&.authorization_code
    self.cae_expiracy = cae_expiracy
    self.invoice = invoice
    self.render_url = build_render_url
  end

  private

  def build_render_url
    return unless token

    Rails.application.routes.url_helpers.export_invoice_url(
      token,
      format: :pdf,
    )
  end
end
