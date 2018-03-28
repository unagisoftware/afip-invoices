# frozen_string_literal: true

class InvoicesServiceMock < AfipMock
  ENDPOINT = %r{/wsfev1/service.asmx}i

  def ws_wsdl
    WebMock
      .stub_request(:get, /#{ENDPOINT}\?wsdl$/i)
      .to_return(body: File.read('spec/support/responses/wsfe_wsdl.xml'))
  end

  def bill_types
    stub_action(
      soap_action: :fe_param_get_tipos_cbte,
      response_body: File.read('spec/support/responses/bill_types_response.xml'),
    )
  end

  def concept_types
    stub_action(
      soap_action: :fe_param_get_tipos_concepto,
      response_body: File.read('spec/support/responses/concept_types_response.xml'),
    )
  end

  def currencies
    stub_action(
      soap_action: :fe_param_get_tipos_monedas,
      response_body: File.read('spec/support/responses/currencies_response.xml'),
    )
  end

  def document_types
    stub_action(
      soap_action: :fe_param_get_tipos_doc,
      response_body: File.read('spec/support/responses/document_types_response.xml'),
    )
  end

  def iva_types
    stub_action(
      soap_action: :fe_param_get_tipos_iva,
      response_body: File.read('spec/support/responses/iva_types_response.xml'),
    )
  end

  def sale_points
    stub_action(
      soap_action: :fe_param_get_ptos_venta,
      response_body: File.read('spec/support/responses/sale_points_response.xml'),
    )
  end

  def sale_points_error
    stub_action(
      soap_action: :fe_param_get_ptos_venta,
      response_body: File.read('spec/support/responses/sale_points_error_response.xml'),
    )
  end

  def optionals
    stub_action(
      soap_action: :fe_param_get_tipos_opcional,
      response_body: File.read('spec/support/responses/optionals_response.xml'),
    )
  end

  def other_sale_points
    stub_action(
      soap_action: :fe_param_get_ptos_venta,
      response_body: File.read('spec/support/responses/other_sale_points_response.xml'),
    )
  end

  def tax_types
    stub_action(
      soap_action: :fe_param_get_tipos_tributos,
      response_body: File.read('spec/support/responses/tax_types_response.xml'),
    )
  end

  def invoice
    stub_action(
      soap_action: :fe_comp_consultar,
      response_body: File.read('spec/support/responses/invoice_response.xml'),
    )
  end

  def product_invoice
    stub_action(
      soap_action: :fe_comp_consultar,
      response_body: File.read('spec/support/responses/product_invoice_response.xml'),
    )
  end

  def invoice_not_found
    stub_action(
      soap_action: :fe_comp_consultar,
      response_body: File.read('spec/support/responses/invoice_not_found_response.xml'),
    )
  end

  def last_bill_number
    stub_action(
      soap_action: :fe_comp_ultimo_autorizado,
      response_body: File.read('spec/support/responses/last_bill_number_response.xml'),
    )
  end

  def create_invoice
    stub_action(
      soap_action: :fecae_solicitar,
      response_body: File.read('spec/support/responses/create_invoice_response.xml'),
    )
  end

  def create_invoice_error
    stub_action(
      soap_action: :fecae_solicitar,
      response_body: File.read('spec/support/responses/create_invoice_error_response.xml'),
    )
  end

  private

  def endpoint
    ENDPOINT
  end
end
