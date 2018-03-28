# frozen_string_literal: true

require 'test_helper'
require 'shared_examples/shared_examples_for_afip'

describe Afip::InvoicesService do
  let(:entity) { create(:entity) }

  subject { described_class.new(entity) }

  describe '#call' do
    context 'when fetching bill types' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:bill_types),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fe_param_get_tipos_cbte
    end

    context 'when fetching concept types' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:concept_types),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fe_param_get_tipos_concepto
    end

    context 'when fetching currencies' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:currencies),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fe_param_get_tipos_monedas
    end

    context 'when fetching document types' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:document_types),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fe_param_get_tipos_doc
    end

    context 'when fetching IVA types' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:iva_types),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fe_param_get_tipos_iva
    end

    context 'when fetching sale points' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:sale_points),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fe_param_get_ptos_venta
    end

    context 'when fetching tax types' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:tax_types),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fe_param_get_tipos_tributos
    end

    context 'when fetching invoice' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:invoice),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fe_comp_consultar
    end

    context 'when fetching last bill number' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:last_bill_number),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fe_comp_ultimo_autorizado
    end

    context 'when creating invoice' do
      let!(:afip_mocks) do
        [
          AfipMock.mock(:login_wsdl),
          AfipMock.mock(:login),
          InvoicesServiceMock.mock(:ws_wsdl),
          InvoicesServiceMock.mock(:create_invoice),
        ]
      end

      it_behaves_like 'AFIP WS operation execution',
        :fecae_solicitar
    end
  end
end
