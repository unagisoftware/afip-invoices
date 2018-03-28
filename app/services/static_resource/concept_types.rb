# frozen_string_literal: true

module StaticResource
  class ConceptTypes < Base
    private

    def operation
      :fe_param_get_tipos_concepto
    end

    def resource
      :concepto_tipo
    end
  end
end
