# frozen_string_literal: true

module StaticResource
  class IvaTypes < Base
    EXEMPT_ID = 98
    UNTAXED_ID = 99

    private

    def operation
      :fe_param_get_tipos_iva
    end

    def resource
      :iva_tipo
    end

    def format_response(response)
      result = super(response)

      return result if result.is_a?(Hash) && result.key?(:error)

      result << { id: IvaTypes::EXEMPT_ID.to_s, name: 'Exento' }
      result << { id: IvaTypes::UNTAXED_ID.to_s, name: 'No gravado' }

      result
    end
  end
end
