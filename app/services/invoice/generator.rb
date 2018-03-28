# frozen_string_literal: true

class Invoice
  class Generator
    attr_reader :errors, :afip_errors, :invoice_id

    def initialize(params, entity, invoice_id_client)
      build_params(params)

      @entity = entity
      @errors = Validator.new(@params).call
      @afip_manager = Afip::Manager.new(@entity)
      @afip_errors = []
      @invoice_id = invoice_id_client[:external_id]
      @logger = Loggers::Invoice.new
    end

    def call
      return build_response(success: false) if errors.any?

      if invoice_persisted?
        process_persisted_invoice

        return build_response(new_record: false)
      end

      queued_invoice = Queue.pop(@invoice_id)

      if queued_invoice.present?
        @logger.debug(action: 'Processing queued invoice', data: { queued_invoice_id: queued_invoice.id })

        invoice = @afip_manager.find_invoice(queued_invoice)

        queued_invoice.delete

        if invoice.present?
          process_enqueued_invoice(invoice)
          return build_response
        end
      end

      generate_invoice
    end

    private

    def build_params(params)
      @params = params

      @params[:associated_invoices] ||= []
      @params[:taxes] ||= []
      @params[:iva] ||= []
      @params[:created_at] ||= Time
        .zone
        .now
        .strftime(Invoice::Schema::DATE_FORMAT)
    end

    def generate_invoice
      @params.merge!(bill_number: bill_number)

      Queue.push(@params[:bill_type_id], invoice_id, @params[:sale_point_id], @params[:bill_number], @entity)

      request_invoice

      if @response[:cae]
        create_invoice(@response[:cae])
        Queue.remove(@invoice_id)
        build_response
      else
        build_response(success: false)
      end
    rescue StandardError => e
      @logger.error(message: e, parameters: @params, response: @response)

      raise e
    end

    def request_invoice
      @logger.debug(action: 'Creating AFIP invoice', data: { bill_number: bill_number })

      data = @afip_manager.request_invoice(@params)

      @logger.debug(action: 'Returned AFIP response', data: data)

      @response = data[:response]
      @afip_errors = data[:errors]

      @logger.debug(action: 'Returned AFIP CAE', data: { cae: @response[:cae] })

      return if @response[:cae_fch_vto].blank?

      @cae_expiracy = Date
        .parse(@response[:cae_fch_vto], Invoice::Schema::DATE_FORMAT)
        .strftime('%d/%m/%Y')
    end

    def create_invoice(cae)
      @logger.debug(action: 'Creating local invoice', data: { cae: cae })

      @invoice = Creator.new(
        bill_number: bill_number,
        cae: cae,
        entity: @entity,
        params: @params,
      ).call
    end

    def process_persisted_invoice
      @logger.debug(action: 'Returning persisted invoice')

      build_bill_number
      build_cae_expiracy
    end

    def process_enqueued_invoice(invoice)
      @logger.debug(action: 'Processing created AFIP invoice', data: { bill_number: invoice[:bill_number] })
      build_bill_number(invoice)
      @cae_expiracy = invoice[:expiracy_date]
      create_invoice(invoice[:authorization_code])
    end

    def bill_number
      return @bill_number if @bill_number

      @bill_number = @afip_manager.next_bill_number(
        @params[:sale_point_id],
        @params[:bill_type_id],
      )
    end

    def invoice_persisted?
      @invoice = Invoice.find_by(
        bill_type_id: @params[:bill_type_id],
        receipt: @params[:recipient_number],
      )

      !!@invoice
    end

    def build_bill_number(invoice = nil)
      @bill_number =
        if invoice
          invoice[:bill_number][5..12].to_i
        else
          @invoice.bill_number
        end
    end

    def build_cae_expiracy
      @cae_expiracy = @invoice[:emission_date].strftime('%d/%m/%Y')
    end

    def build_response(new_record: true, success: true)
      Generator::Result.new(
        afip_errors: @afip_errors,
        cae_expiracy: @cae_expiracy,
        errors: @errors,
        invoice: @invoice,
        new_record: new_record,
        success: success,
      )
    end
  end
end
