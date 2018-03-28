# frozen_string_literal: true

module V1
  class InvoicesController < ApplicationController
    skip_before_action :authenticate, only: [:export]
    before_action :fetch_invoice, only: %i[show export]

    ITEM_PARAMS = %i[
      quantity
      unit_price
      description
      bonus_percentage
      code
      metric_unit
      iva_aliquot_id
    ].freeze

    ASSOCIATED_INVOICE_PARAMS = %i[
      bill_type_id sale_point_id number date cuit rejected
    ].freeze

    IVA_PARAMS = %i[
      id net_amount total_amount
    ].freeze

    TAX_PARAMS = %i[
      id description net_amount rate total_amount
    ].freeze

    INVOICE_PARAMS = [
      :sale_point_id, :concept_type_id, :recipient_type_id,
      :recipient_number, :net_amount, :iva_amount, :untaxed_amount,
      :exempt_amount, :tax_amount, :bill_type_id, :created_at,
      :total_amount, :service_from, :service_to, :due_date, :note,
      :cbu, :alias, :transmission,
      {
        associated_invoices: [ASSOCIATED_INVOICE_PARAMS],
        taxes: [TAX_PARAMS],
        iva: [IVA_PARAMS],
        items: [ITEM_PARAMS],
      }
    ].freeze

    CREATION_RESULT_STATUS = {
      created: :created,
      existing: :ok,
      in_progress: :continue,
    }.freeze

    def index
      render json: entity.invoices
    end

    def show
      if @invoice
        render json: Invoice::Finder.new(
          invoice: @invoice,
          entity: entity,
        ).run
      else
        render_not_found
      end
    end

    def create
      generation = Invoice::Generator.new(invoice_params, entity, invoice_client_identifier).call

      if generation.with_errors?
        render json: {
          afip_errors: generation.afip_errors,
          errors: generation.errors,
        }, status: :bad_request
      else
        render json: generation.represented_invoice,
          status: CREATION_RESULT_STATUS[generation.status]
      end
    end

    def details
      invoice = Invoice::Finder.new(
        params: invoice_details_params,
        entity: entity,
      ).run

      if invoice
        render json: invoice
      else
        render_not_found
      end
    end

    def export
      if @invoice
        respond_to do |format|
          format.pdf { send_pdf(@invoice) }
        end
      else
        render_not_found
      end
    end

    def export_preview
      invoice = Invoice::Builder.new(invoice_preview_params, @entity).call

      respond_to do |format|
        format.pdf { send_pdf(invoice, invoice_preview_params) }
      end
    end

    private

    def invoice_params
      params.permit(*INVOICE_PARAMS)
    end

    def invoice_preview_params
      params.permit(:bill_number, *INVOICE_PARAMS)
    end

    def invoice_details_params
      params.permit(:bill_number, :sale_point_id, :bill_type_id)
    end

    def invoice_client_identifier
      params.permit(:external_id)
    end

    def send_pdf(invoice, invoice_data = nil)
      invoice_data = Invoice::DataFormatter.new(invoice_data).call if invoice_data

      send_data InvoicePdf.new(invoice, invoice_data).render,
        filename: 'factura.pdf',
        type: 'application/pdf',
        disposition: 'inline'
    end

    def fetch_invoice
      @invoice = Invoice.find_by(token: params[:id])
    end
  end
end
