# frozen_string_literal: true

class Invoice
  class Generator
    class Result
      attr_reader :afip_errors, :cae_expiracy, :errors, :invoice, :new_record, :success

      delegate :persisted?, to: :invoice, allow_nil: true

      def initialize(invoice:, cae_expiracy:, new_record:, errors:, afip_errors:, success:)
        @afip_errors = afip_errors || []
        @cae_expiracy = cae_expiracy
        @errors = errors || []
        @invoice = invoice
        @new_record = new_record
        @success = success
      end

      def represented_invoice
        @represented_invoice ||= GeneratedInvoiceRepresenter.new(
          bill: invoice&.receipt,
          cae_expiracy: cae_expiracy,
          invoice: invoice,
        )
      end

      def status
        return :in_progress unless finished?

        new_record? ? :created : :existing
      end

      def with_errors?
        !success && (errors.any? || afip_errors.any?)
      end

      private

      def new_record?
        new_record
      end

      def finished?
        invoice && persisted?
      end
    end
  end
end
