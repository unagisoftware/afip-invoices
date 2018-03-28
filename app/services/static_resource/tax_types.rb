# frozen_string_literal: true

module StaticResource
  class TaxTypes < Base
    private

    def operation
      :fe_param_get_tipos_tributos
    end

    def resource
      :tributo_tipo
    end
  end
end
