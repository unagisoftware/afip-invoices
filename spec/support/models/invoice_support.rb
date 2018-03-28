# frozen_string_literal: true

class InvoiceSupport
  QR_FORMAT = {
    codAut: Integer,
    ctz: Float,
    cuit: Integer,
    fecha: String,
    importe: Float,
    moneda: String,
    nroCmp: Integer,
    nroDocRec: Integer,
    ptoVta: Integer,
    tipoCmp: Integer,
    tipoCodAut: String,
    tipoDocRec: Integer,
    ver: Integer,
  }.freeze
end
