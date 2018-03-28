# frozen_string_literal: true

class InvoiceItem < ApplicationRecord
  validates :bonus_percentage, presence: true
  validates :description, presence: true
  validates :quantity, presence: true
  validates :unit_price, presence: true

  belongs_to :invoice

  def total
    (subtotal * (1 - bonus_coefficient)).round(2)
  end

  def bonus_amount
    (subtotal * bonus_coefficient).round(2)
  end

  def iva_aliquot
    iva_record = StaticResource::IvaTypes.new(invoice.entity).call.find do |iva_type|
      iva_type[:id].to_i == iva_aliquot_id
    end

    iva_record ||= { id: '99', name: 'No gravado' }

    iva_record[:name]
      .gsub('%', '')
      .gsub(',', '.')
      .strip
      .to_f
  end

  def exempt?
    iva_aliquot_id == StaticResource::IvaTypes::EXEMPT_ID
  end

  def untaxed?
    iva_aliquot_id == StaticResource::IvaTypes::UNTAXED_ID
  end

  private

  def subtotal
    quantity * unit_price
  end

  def bonus_coefficient
    bonus_percentage / 100
  end
end
