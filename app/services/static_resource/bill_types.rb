# frozen_string_literal: true

module StaticResource
  class BillTypes < Base
    SHORT_NAMES = {
      "Factura A": 'A',
      "Factura B": 'B',
      "Factura C": 'C',
      "Nota de Débito A": 'NDA',
      "Nota de Débito B": 'NDB',
      "Nota de Débito C": 'NDC',
      "Nota de Crédito A": 'NCA',
      "Nota de Crédito B": 'NCB',
      "Nota de Crédito C": 'NCC',
      "Recibos A": 'A',
      "Recibos B": 'B',
      "Recibo C": 'C',
      "Factura de Crédito electrónica MiPyMEs (FCE) A": 'FCEA',
      "Factura de Crédito electrónica MiPyMEs (FCE) B": 'FCEB',
      "Factura de Crédito electrónica MiPyMEs (FCE) C": 'FCEC',
      "Nota de Crédito electrónica MiPyMEs (FCE) A": 'NCEA',
      "Nota de Crédito electrónica MiPyMEs (FCE) B": 'NCEB',
      "Nota de Crédito electrónica MiPyMEs (FCE) C": 'NCEC',
      "Nota de Débito electrónica MiPyMEs (FCE) A": 'NDEA',
      "Nota de Débito electrónica MiPyMEs (FCE) B": 'NDEB',
      "Nota de Débito electrónica MiPyMEs (FCE) C": 'NDEC',
    }.freeze

    private

    def operation
      :fe_param_get_tipos_cbte
    end

    def resource
      :cbte_tipo
    end
  end
end
