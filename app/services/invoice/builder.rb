# frozen_string_literal: true

class Invoice
  class Builder
    def initialize(params, entity)
      @params = params
      @entity = entity

      @params[:associated_invoices] ||= []
      @params[:taxes] ||= []
      @params[:iva] ||= []
      @params[:created_at] ||= Time
        .zone
        .now
        .strftime(Invoice::Schema::DATE_FORMAT)
    end

    def call
      build_invoice

      Invoice::RecipientLoader.new(@invoice).call(@params[:recipient_number])

      build_items
      build_associated_invoices

      @invoice
    end

    private

    def build_invoice
      @invoice = Invoice.new(
        entity: @entity,
        emission_date: @params[:created_at],
        authorization_code: nil,
        receipt: bill,
        bill_type_id: @params[:bill_type_id],
        logo_url: @entity.logo.to_s,
        note: @params[:note],
        cbu: @params[:cbu],
        alias: @params[:alias],
      )
    end

    def build_items
      return unless @params[:items]

      @params[:items].each { |item| build_item(item) }
    end

    def build_item(item)
      @invoice.items.build(
        code: item[:code],
        description: item[:description],
        unit_price: item[:unit_price],
        quantity: item[:quantity] || 1,
        bonus_percentage: item[:bonus_percentage] || 0,
        metric_unit: item[:metric_unit] || Invoice::Generator::DEFAULT_ITEM_UNIT,
        iva_aliquot_id: item[:iva_aliquot_id],
      )
    end

    def build_associated_invoices
      return unless @params[:associated_invoices]

      @params[:associated_invoices].each do |item|
        @invoice.associated_invoices.build(
          invoice: @invoice,
          bill_type_id: item[:bill_type_id],
          emission_date: item[:date],
          receipt: "#{item[:sale_point_id]}-#{item[:number]}",
        )
      end
    end

    def bill
      "#{format('%0004d', @params[:sale_point_id])}-#{format('%008d', @params[:bill_number])}"
    end
  end
end
