# frozen_string_literal: true

module StaticResource
  class SalePoints < Base
    private

    def operation
      :fe_param_get_ptos_venta
    end

    def resource
      :pto_venta
    end

    def format_item(item)
      return unless valid_item?(item)

      {
        id: item[:nro],
        name: item[:nro].rjust(4, '0'),
        type: item[:emision_tipo],
        enabled: item[:bloqueado].to_s.casecmp('N').zero?,
      }
    end

    def valid_item?(item)
      item[:fch_baja] == 'NULL'
    end
  end
end
