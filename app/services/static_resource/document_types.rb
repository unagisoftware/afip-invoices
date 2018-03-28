# frozen_string_literal: true

module StaticResource
  class DocumentTypes < Base
    private

    def operation
      :fe_param_get_tipos_doc
    end

    def resource
      :doc_tipo
    end
  end
end
