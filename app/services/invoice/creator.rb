# frozen_string_literal: true

class Invoice
  class Creator
    DEFAULT_ITEM_UNIT = 'unidades'

    attr_reader :invoice

    def initialize(entity:, params: nil, cae: nil, bill_number: nil)
      @entity = entity
      @params = params
      @cae = cae
      @bill_number = bill_number
    end

    def call
      ActiveRecord::Base.transaction do
        @invoice = Invoice.create!(invoice_params)

        RecipientLoader.new(@invoice).call!(@params[:recipient_number])

        create_items
        create_associated_invoices
      end
      @invoice
    end

    private

    def create_items
      return unless @params[:items]

      @params[:items].each do |item|
        InvoiceItem.create!(items_params(item))
      end
    end

    def create_associated_invoices
      return unless @params[:associated_invoices]

      @params[:associated_invoices].each do |item|
        AssociatedInvoice.create!(associated_invoice_params(item))
      end
    end

    def invoice_params
      {
        entity: @entity,
        emission_date: @params[:created_at],
        authorization_code: @cae,
        receipt: bill(@params[:sale_point_id], @bill_number),
        bill_type_id: @params[:bill_type_id],
        logo_url: @entity.logo.to_s,
        note: @params[:note],
        cbu: @params[:cbu],
        alias: @params[:alias],
      }
    end

    def items_params(item)
      {
        invoice: @invoice,
        code: item[:code],
        description: item[:description],
        unit_price: item[:unit_price],
        quantity: item[:quantity] || 1,
        bonus_percentage: item[:bonus_percentage] || 0,
        metric_unit: item[:metric_unit] || DEFAULT_ITEM_UNIT,
        iva_aliquot_id: item[:iva_aliquot_id],
      }
    end

    def associated_invoice_params(item)
      {
        invoice: @invoice,
        bill_type_id: item[:bill_type_id],
        emission_date: item[:date],
        receipt: "#{item[:sale_point_id]}-#{item[:number]}",
      }
    end

    def bill(sale_point_id, bill_number)
      "#{format('%0004d', sale_point_id)}-#{format('%008d', bill_number)}"
    end
  end
end
