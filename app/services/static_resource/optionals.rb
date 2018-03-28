# frozen_string_literal: true

module StaticResource
  class Optionals < Base
    private

    def operation
      :fe_param_get_tipos_opcional
    end

    def resource
      :opcional_tipo
    end
  end
end
