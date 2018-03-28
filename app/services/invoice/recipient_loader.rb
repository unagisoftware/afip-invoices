# frozen_string_literal: true

class Invoice
  class RecipientLoader
    attr_reader :invoice

    delegate :entity, to: :invoice

    def initialize(invoice)
      @invoice = invoice
    end

    def call(recipient_cuit = nil)
      unless recipient_cuit
        invoice_data = Invoice::Finder.new(entity: entity, invoice: invoice).run
        return false if invoice_data.nil?

        recipient_cuit = invoice_data.recipient_number
      end

      person_data = nil

      begin
        person_data = Afip::Person.new({ cuit: recipient_cuit }, entity).info
      rescue StandardError => e
        Rails.logger.error 'No fue posible obtener la información de la persona.'
        Rails.logger.error "Mensaje de error: #{e.message}"

        return false
      end

      invoice.recipient = person_data
    end

    def call!(recipient_cuit = nil)
      call(recipient_cuit)
      invoice.save!
    end
  end
end
