# frozen_string_literal: true

class Invoice
  class QueryBuilder
    include ActiveModel::Model

    CURRENCY      = 'PES'
    QUOTATION     = 1
    RECORDS       = 1
    ANNULMENT_ID  = '22'
    CBU_ID        = '2101'
    ALIAS_ID      = '2102'
    FCE_SYSTEM_ID = '27'

    attr_accessor :sale_point_id, :concept_type_id, :recipient_type_id,
      :recipient_number, :net_amount, :iva_amount, :untaxed_amount,
      :exempt_amount, :tax_amount, :iva, :taxes, :bill_type_id, :created_at,
      :total_amount, :service_from, :service_to, :due_date,
      :associated_invoices, :items, :bill_number, :note, :cbu, :alias, :cuit, :transmission

    def call
      parameters = basic_message

      add_associated_invoices(parameters)
      add_iva_information(parameters)
      add_taxes_information(parameters)
      add_optional_information(parameters)

      parameters
    end

    private

    # rubocop:disable Metrics/MethodLength
    def basic_message
      {
        'FeCAEReq' => {
          'FeCabReq' => {
            'CantReg' => RECORDS,
            'PtoVta' => sale_point_id,
            'CbteTipo' => bill_type_id,
          },
          'FeDetReq' => {
            'FECAEDetRequest' => {
              'Concepto' => concept_type_id,
              'DocTipo' => recipient_type_id,
              'DocNro' => recipient_number,
              'CbteDesde' => bill_number,
              'CbteHasta' => bill_number,
              'CbteFch' => created_at,
              'ImpTotal' => format_amount(total_amount),
              'ImpTotConc' => format_amount(untaxed_amount),
              'ImpNeto' => format_amount(net_amount),
              'ImpOpEx' => format_amount(exempt_amount),
              'ImpTrib' => format_amount(tax_amount),
              'ImpIVA' => format_amount(iva_amount),
              'FchServDesde' => format_date(service_from),
              'FchServHasta' => format_date(service_to),
              'FchVtoPago' => format_date(due_date),
              'MonId' => CURRENCY,
              'MonCotiz' => QUOTATION,
            },
          },
        },
      }
    end
    # rubocop:enable Metrics/MethodLength

    def format_date(date)
      return date if date.nil?

      Date.parse(date, Invoice::Schema::DATE_FORMAT).strftime('%Y%m%d')
    end

    def format_amount(amount)
      Integer(amount.to_f * 100) / 100.0
    end

    def add_associated_invoices(parameters)
      return if associated_invoices.empty?

      data = associated_invoices.map do |invoice|
        {
          'Tipo' => invoice[:bill_type_id],
          'PtoVta' => invoice[:sale_point_id],
          'Nro' => invoice[:number],
          'CbteFch' => format_date(invoice[:date]),
          'Cuit' => cuit,
        }
      end

      parameters['FeCAEReq']['FeDetReq']['FECAEDetRequest']['CbtesAsoc'] = {
        'CbteAsoc' => data,
      }
    end

    def add_iva_information(parameters)
      return if iva.empty?

      data = iva.map do |tax|
        {
          'Id' => tax[:id].to_s,
          'BaseImp' => format_amount(tax[:net_amount]),
          'Importe' => format_amount(tax[:total_amount]),
        }
      end

      parameters['FeCAEReq']['FeDetReq']['FECAEDetRequest']['Iva'] = {
        'AlicIva' => data,
      }
    end

    def add_taxes_information(parameters)
      return if taxes.empty?

      data = taxes.map do |tax|
        {
          'Id' => tax[:id].to_s,
          'Desc' => tax[:description],
          'BaseImp' => format_amount(tax[:net_amount]),
          'Alic' => tax[:rate],
          'Importe' => format_amount(tax[:total_amount]),
        }
      end

      parameters['FeCAEReq']['FeDetReq']['FECAEDetRequest']['Tributos'] = {
        'Tributo' => data,
      }
    end

    def add_optional_information(parameters)
      data = []

      if electronic_credit_invoice?
        data.push({ 'Id' => CBU_ID, 'Valor' => cbu })
        data.push({ 'Id' => ALIAS_ID, 'Valor' => @alias }) if @alias
        data.push({ 'Id' => FCE_SYSTEM_ID, 'Valor' => @transmission })
      end

      if electronic_note?
        data.push({
          'Id' => ANNULMENT_ID,
          'Valor' => existing_rejected_associated_invoices? ? 'S' : 'N',
        })
      end

      return if data.empty?

      parameters['FeCAEReq']['FeDetReq']['FECAEDetRequest']['Opcionales'] = {
        'Opcional' => data,
      }
    end

    def electronic_credit_invoice?
      Invoice::Schema::ELECTRONIC_CREDIT_INVOICES_IDS.include?(bill_type_id)
    end

    def electronic_note?
      Invoice::Schema::ELECTRONIC_NOTES_IDS.include?(bill_type_id)
    end

    def existing_rejected_associated_invoices?
      associated_invoices.any? { |invoice| invoice[:rejected] == true }
    end
  end
end
