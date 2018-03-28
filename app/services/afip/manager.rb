# frozen_string_literal: true

module Afip
  class Manager
    def initialize(entity)
      @entity = entity
      @afip = InvoicesService.new(entity)
    end

    def request_invoice(params)
      message = Invoice::QueryBuilder
        .new(params.merge(cuit: @entity.cuit))
        .call

      data = @afip.call(:fecae_solicitar, message)

      {
        response: request_invoice_response(data),
        errors: request_invoice_errors(data),
      }
    end

    def find_invoice(invoice)
      Invoice::Finder.new(
        params: { bill_number: invoice.bill_number,
                  sale_point_id: invoice.sale_point_id,
                  bill_type_id: invoice.bill_type_id },
        entity: @entity,
      ).run
    end

    def next_bill_number(sale_point_id, bill_type_id)
      response = @afip.call(:fe_comp_ultimo_autorizado, {
        'PtoVta' => sale_point_id,
        'CbteTipo' => bill_type_id,
      })

      response[:fe_comp_ultimo_autorizado_response][:fe_comp_ultimo_autorizado_result][:cbte_nro].to_i + 1
    end

    private

    def request_invoice_response(data)
      data[:fecae_solicitar_response][:fecae_solicitar_result][:fe_det_resp][:fecae_det_response]
    end

    def request_invoice_errors(data)
      errors = Array.wrap(data.dig(:fecae_solicitar_response, :fecae_solicitar_result, :errors,
        :err)).map do |error|
        "#{error[:msg]} (error #{error[:code]})"
      end

      errors += Array.wrap(request_invoice_response(data)[:observaciones]).flat_map do |error|
        Array.wrap(error[:obs]).map do |item|
          "#{item[:msg]} (error #{item[:code]})"
        end
      end

      errors
    end
  end
end
