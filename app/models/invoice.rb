# frozen_string_literal: true

class Invoice < ApplicationRecord
  include Invoiceable

  has_secure_token

  validates :authorization_code, presence: true

  belongs_to :entity
  has_many :associated_invoices, dependent: :destroy
  has_many :items, class_name: 'InvoiceItem', dependent: :destroy

  def qr_code
    invoice = Invoice::Finder.new(invoice: self, entity: entity).run
    # Version of the format of the bill (1 character)
    # Emission date of the bill (8 characters) - YYYYMMDD
    # C.U.I.T. of the issuer of the bill (11 characters)
    # Sale point (5 characters)
    # Bill type code (3 characters)
    # Bill number (8 characters)
    # Total amount (15 characters)
    # Currency id(3 characters)
    # Quotation in pesos (19 characters)
    # Recipient type id (2 characters)
    # Recipient number (20 characters)
    # Authorization type code
    # Authorization Code (C.A.I.) (14 characters)
    {
      'ver' => invoice[:concept_type_id].to_i,
      'fecha' => emission_date.strftime('%Y-%m-%d'),
      'cuit' => entity.cuit.to_i,
      'ptoVta' => sale_point_id.to_i,
      'tipoCmp' => bill_type_id,
      'nroCmp' => bill_number.to_i,
      'importe' => invoice[:total_amount].to_f,
      'moneda' => invoice[:currency_id],
      'ctz' => invoice[:quotation].to_f,
      'tipoDocRec' => invoice[:recipient_type_id].to_i,
      'nroDocRec' => invoice[:recipient_number].to_i,
      'tipoCodAut' => invoice[:emission_type] == 'CAE' ? 'E' : 'A',
      'codAut' => authorization_code.to_i,
    }.to_json
  end

  def fce?
    Invoice::Schema::ELECTRONIC_CREDIT_INVOICES_IDS
      .map(&:to_i)
      .include?(bill_type_id)
  end

  def note?
    Invoice::Schema::NOTES_IDS.map(&:to_i).include?(bill_type_id) ||
      Invoice::Schema::ELECTRONIC_NOTES_IDS.map(&:to_i).include?(bill_type_id)
  end
end
