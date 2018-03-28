# frozen_string_literal: true

class Invoice
  class DataFormatter
    DATETIME_FORMAT = '%Y%m%d%H%M%S'

    def initialize(data)
      @data = data.dup
    end

    def call
      format_bill
      format_amounts
      format_dates

      @data
    end

    private

    def format_bill
      @data[:sale_point_id] = @data[:sale_point_id].to_s.rjust(4, '0')
      @data[:bill_number]   = @data[:bill_number].to_s.rjust(8, '0')
    end

    def format_amounts
      %i[iva taxes].each do |key|
        @data[key] ||= []

        @data[key].each do |item|
          item[:net_amount] = item[:net_amount].to_f
          item[:total_amount] = item[:total_amount].to_f

          item[:rate] = item[:rate].to_f if item[:rate]
        end
      end

      @data[:tax_amount] = @data[:tax_amount].to_f if @data[:tax_amount]
    end

    def format_dates
      %i[service_from service_to due_date expiracy_date].each do |key|
        @data[key] = format_date(@data[key])
      end

      @data[:created_at] = format_datetime(@data[:created_at])
    end

    def format_date(date)
      return if date.blank?

      Date
        .parse(date, Invoice::Schema::DATE_FORMAT)
        .strftime('%d/%m/%Y')
    end

    def format_datetime(datetime)
      return if datetime.blank?

      DateTime
        .parse(datetime, DATETIME_FORMAT)
        .strftime('%d/%m/%Y %H:%M:%S')
    end
  end
end
