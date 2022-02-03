# frozen_string_literal: true

class AfipPersonRepresenter < OpenStruct
  include Representable::JSON

  IVA_TAX_ID = 30

  attr_reader :data

  property :address
  property :category
  property :city
  property :full_address
  property :name
  property :state
  property :zipcode

  def initialize(data:)
    @data = data

    super()

    self.address = personal_data[:domicilio_fiscal][:direccion]
    self.category = build_category
    self.city = personal_data[:domicilio_fiscal][:localidad]
    self.full_address = build_full_address
    self.name = build_name
    self.state = personal_data[:domicilio_fiscal][:descripcion_provincia]
    self.zipcode = personal_data[:domicilio_fiscal][:cod_postal]
  end

  private

  def personal_data
    data[:datos_generales]
  end

  def build_full_address
    "#{personal_data[:domicilio_fiscal][:direccion]} "\
      "#{personal_data[:domicilio_fiscal][:localidad]}, "\
      "#{personal_data[:domicilio_fiscal][:descripcion_provincia]} "
  end

  def build_name
    return personal_data[:razon_social] if personal_data[:tipo_persona] == 'JURIDICA'

    "#{personal_data[:nombre]} #{personal_data[:apellido]}"
  end

  def build_category
    return 'Monotributista' if data.key?(:datos_monotributo)

    if data[:datos_regimen_general].present?
      taxes = Array.wrap(data[:datos_regimen_general][:impuesto])
      return 'Responsable inscripto' if taxes.any? { |x| x[:id_impuesto].to_i == IVA_TAX_ID }
    end

    Rails.logger.warn 'No fue posible determinar la categoría de la persona. '\
      "Respuesta recibida: #{::JSON.dump(data)}"

    nil
  end
end
