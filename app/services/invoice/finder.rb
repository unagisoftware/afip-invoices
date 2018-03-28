# frozen_string_literal: true

class Invoice
  class Finder
    include ActiveModel::Model

    TTL = 2.minutes

    attr_accessor :afip,
      :bill_type_id,
      :bill_number,
      :items,
      :response,
      :sale_point_id

    def initialize(entity:, params: nil, invoice: nil)
      if params.present?
        super(params)
      else
        build_params(invoice)
      end

      @afip = Afip::InvoicesService.new(entity)
    end

    def run
      return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

      @response = afip.call(:fe_comp_consultar, message)

      return if errors?

      invoice = represent_invoice

      Rails.cache.write(cache_key, invoice, expires_in: TTL)

      invoice
    end

    private

    def build_params(invoice)
      @bill_type_id  = invoice.bill_type_id
      @sale_point_id = invoice.sale_point_id
      @bill_number   = invoice.bill_number

      @items = invoice.items.map do |item|
        {
          decription: item.description,
          quantity: item.quantity,
          unit_price: item.unit_price,
          metric_unit: item.metric_unit,
          total: item.total,
          bonus_amount: item.bonus_amount,
          bonus_percentage: item.bonus_percentage,
        }
      end
    end

    def message
      {
        'FeCompConsReq' => {
          'CbteTipo' => bill_type_id,
          'CbteNro' => bill_number,
          'PtoVta' => sale_point_id,
        },
      }
    end

    def errors?
      response[:fe_comp_consultar_response][:fe_comp_consultar_result][:errors].present?
    end

    def represent_invoice
      data = response.dig(
        :fe_comp_consultar_response,
        :fe_comp_consultar_result,
        :result_get,
      )

      InvoiceWithDetailsRepresenter.new(
        bill_number: bill_number,
        bill_type_id: bill_type_id,
        data: data,
        items: items,
        sale_point_id: sale_point_id,
      )
    end

    def cache_key
      "#{afip.entity_cuit}/#{sale_point_id}/#{bill_type_id}/#{bill_number}"
    end
  end
end
