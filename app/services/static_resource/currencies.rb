# frozen_string_literal: true

module StaticResource
  class Currencies < Base
    private

    def operation
      :fe_param_get_tipos_monedas
    end

    def resource
      :moneda
    end
  end
end
