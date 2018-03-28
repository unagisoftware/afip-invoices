# frozen_string_literal: true

class Invoice
  # rubocop:disable Metrics/ClassLength
  class Validator
    include ActiveModel::Model

    attr_accessor :sale_point_id, :concept_type_id, :recipient_type_id,
      :recipient_number, :net_amount, :iva_amount, :untaxed_amount,
      :exempt_amount, :tax_amount, :iva, :taxes, :bill_type_id, :created_at,
      :total_amount, :service_from, :service_to, :due_date,
      :associated_invoices, :items, :note, :cbu, :alias, :transmission

    def call
      @errors = []

      validate_required_attributes

      return @errors if @errors.any?

      validate_amount_attributes

      return @errors if @errors.any?

      validate_custom_attributes
      validate_items

      @errors
    end

    private

    def validate_required_attributes
      Invoice::Schema::REQUIRED_ATTRIBUTES.each do |attr, name|
        @errors << "#{name} requerido (#{attr})" if send(attr).blank?
      end
    end

    def validate_amount_attributes
      Invoice::Schema::NUMERIC_ATTRIBUTES.each do |attr, name|
        @errors << "#{name} debe ser un número (#{attr})" unless Invoice::Schema::FLOAT_REGEX === send(attr).to_s

        if send(attr).to_f.negative?
          @errors << "#{Invoice::Schema::REQUIRED_ATTRIBUTES[attr]} no puede ser negativo (#{attr})"
        end
      end

      return if @errors.any?

      total = untaxed_amount.to_f +
              exempt_amount.to_f +
              net_amount.to_f +
              iva_amount.to_f +
              tax_amount.to_f

      @errors << 'Importe total no se condice con importes informados' if (total - total_amount.to_f).abs > 0.1
    end

    def validate_custom_attributes
      @errors << 'Concepto no válido' if Invoice::Schema::CONCEPTS.values.exclude?(concept_type_id.to_i)

      validate_created_at
      validate_service_dates
      validate_iva_net if iva.any?
      validate_amounts(iva_amount.to_f, iva, 'IVA')
      validate_amounts(tax_amount.to_f, taxes, 'tributos')

      if Invoice::Schema::ELECTRONIC_CREDIT_INVOICES_IDS.include?(bill_type_id)
        validate_fce_authorization_request
        validate_fce_required_attributes
      elsif Invoice::Schema::NOTES_IDS.include?(bill_type_id.to_s)
        validate_associated_invoices
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity:
    # rubocop:disable Metrics/PerceivedComplexity
    def validate_created_at
      @errors << 'Fecha de comprobante inválida o inexistente (created_at)' unless valid_date?(created_at)

      date = Date.parse(created_at, Invoice::Schema::DATE_FORMAT)

      valid_date =
        case concept_type_id.to_i
        when Invoice::Schema::CONCEPTS[:products]
          (5.days.ago.to_date..5.days.from_now.to_date).include?(date)
        when Invoice::Schema::CONCEPTS[:services]
          (10.days.ago.to_date..10.days.from_now.to_date).include?(date)
        when Invoice::Schema::CONCEPTS[:products_and_services]
          (10.days.ago.to_date..10.days.from_now.to_date).include?(date)
        end

      @errors << 'Fecha de comprobante fuera de rango (created_at)' unless valid_date
    rescue ArgumentError
      false
    end

    def validate_service_dates
      validable = [
        Invoice::Schema::CONCEPTS[:services],
        Invoice::Schema::CONCEPTS[:products_and_services],
      ].include?(concept_type_id.to_i)

      return unless validable

      @errors << 'Fecha desde inválida o inexistente (service_from)' unless valid_date?(service_from)

      @errors << 'Fecha hasta inválida o inexistente (service_to)' unless valid_date?(service_to)

      if !valid_date?(due_date) && !Invoice::Schema::ELECTRONIC_NOTES_IDS.include?(bill_type_id.to_s)
        @errors << 'Fecha de vencimiento inválida o inexistente (due_date)'
      end

      return unless service_from && service_to && due_date

      from    = Date.parse(service_from, Invoice::Schema::DATE_FORMAT)
      to      = Date.parse(service_to, Invoice::Schema::DATE_FORMAT)
      due     = Date.parse(due_date, Invoice::Schema::DATE_FORMAT)
      invoice = Date.parse(created_at, Invoice::Schema::DATE_FORMAT)

      @errors << 'Fecha desde es posterior a fecha hasta' if from > to

      @errors << 'Fecha de vencimiento es anterior a fecha de comprobante' if invoice > due
    rescue ArgumentError
      false
    end
    # rubocop:enable Metrics/CyclomaticComplexity:
    # rubocop:enable Metrics/PerceivedComplexity

    def valid_date?(date)
      date.present? && (Invoice::Schema::DATE_REGEX === date)
    end

    def validate_amounts(total, amounts, name)
      return if (total.blank? || total.zero?) &&
                amounts.empty?

      reduced = amounts
        .reduce(0) { |sum, tax| sum + tax[:total_amount].to_f }

      @errors << "#{name.capitalize} ingresados no compensan el total de #{name}" if (total - reduced).abs > 0.1
    end

    def validate_iva_net
      reduced = iva.reduce(0) { |sum, tax| sum + tax[:net_amount].to_f }

      return unless (net_amount - reduced).abs > 0.1

      @errors << 'Suma de netos de IVA ingresados no compensan el neto del comprobante'
    end

    def validate_items
      return true if items.blank?

      items.each { |item| validate_item_format(item) }

      validate_items_amount
    end

    def validate_item_format(item)
      Invoice::Schema::ITEM_REQUIRED_ATTRIBUTES.each do |attr, name|
        @errors << "#{name} de item requerido (#{attr} en item)" if item[attr].blank?
      end

      Invoice::Schema::ITEM_NUMERIC_ATTRIBUTES.each do |attr, name|
        unless Invoice::Schema::FLOAT_REGEX === item[attr].to_s
          @errors << "#{name} de item debe ser un número (#{attr} en item)"
        end
      end
    end

    def validate_items_amount
      exempt_items, other_items = items.partition do |item|
        item[:iva_aliquot_id].to_i == StaticResource::IvaTypes::EXEMPT_ID
      end

      untaxed_items, other_items = other_items.partition do |item|
        item[:iva_aliquot_id].to_i == StaticResource::IvaTypes::UNTAXED_ID
      end

      validate_net_amount(other_items)
      validate_exempt_amount(exempt_items)
      validate_untaxed_amount(untaxed_items)
    end

    def validate_net_amount(other_items)
      return unless (items_total(other_items).round(2) - net_amount).abs > 0.1

      @errors << 'El subtotal de los items ingresados no suma el neto gravado'
    end

    def validate_exempt_amount(exempt_items)
      return unless (items_total(exempt_items).round(2) - exempt_amount).abs > 0.1

      @errors << 'La suma de los valores exentos de los items no coincide con el total exento provisto'
    end

    def validate_untaxed_amount(untaxed_items)
      return unless (items_total(untaxed_items).round(2) - untaxed_amount).abs > 0.1

      @errors << 'La suma de los valores no gravados de los items no coincide con el total no gravado provisto'
    end

    def items_total(items)
      items.reduce(0) do |sum, item|
        subtotal = item[:quantity].to_f *
                   item[:unit_price].to_f *
                   (1 - (item[:bonus_percentage].to_f / 100))

        sum + subtotal
      end
    end

    # La autorización de la FCE MiPyME podrá efectuarse dentro de los 5 días corridos
    # anteriores o 1 día posterior a la fecha de emisión de la misma. En caso de
    # ser anterior, deberá corresponder al mismo mes que el de la fecha de emisión.
    def validate_fce_authorization_request
      created_at_date = created_at.to_date
      valid_days = (created_at_date - 5)..(created_at_date + 1)

      inside_range = valid_days.include? Date.current
      date_in_past = Date.current < created_at_date
      equal_month  = Date.current.month.eql? created_at_date.month

      return if (inside_range && !date_in_past) ||
                (inside_range && date_in_past && equal_month)

      @errors << 'La solicitud de autorización debe efectuarse dentro de los'\
        ' 5 días corridos anteriores o 1 día posterior a la fecha de emisión'
    end

    def validate_fce_required_attributes
      return if cbu.present? && transmission.present?

      @errors << 'CBU requerido (cbu)' if cbu.blank?
      @errors << 'Transmisión requerida (SCA/ADC)' if transmission.blank?
    end

    def validate_associated_invoices
      if associated_invoices.present?
        associated_invoices.each do |associated_invoice|
          validate_associated_invoice(associated_invoice)
        end
      else
        @errors << 'Comprobantes asociados requeridos (associated_invoices)'
      end
    end

    def validate_associated_invoice(associated_invoice)
      Invoice::Schema::ASSOCIATED_INVOICE_ATTRIBUTES.each do |attr, name|
        if associated_invoice[attr].blank?
          @errors << "#{name} de comprobante asociado requerido (#{attr} en comprobante asociado)"
        end
      end

      return if valid_date?(associated_invoice[:date])

      @errors << 'Fecha de comprobante asociado inválida o inexistente (date en comprobante asociado)'
    end
  end
  # rubocop:enable Metrics/ClassLength
end
