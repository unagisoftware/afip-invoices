# frozen_string_literal: true

class Invoice
  module Queue
    def self.exists?(invoice_id)
      AfipRequest.find_by(invoice_id_client: invoice_id).present?
    end

    def self.push(bill_type_id, invoice_id, sale_point_id, bill_number, entity)
      AfipRequest.create(bill_type_id: bill_type_id,
        invoice_id_client: invoice_id,
        sale_point_id: sale_point_id,
        bill_number: bill_number,
        entity: entity)
    end

    def self.pop(invoice_id)
      AfipRequest.find_by(invoice_id_client: invoice_id)
    end

    def self.remove(invoice_id)
      AfipRequest.find_by(invoice_id_client: invoice_id).delete if exists?(invoice_id)
    end
  end
end
