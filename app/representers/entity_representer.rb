# frozen_string_literal: true

class EntityRepresenter < Representable::Decorator
  include Representable::JSON

  property :auth_token
  property :business_name
  property :completed, exec_context: :decorator
  property :created_at
  property :cuit
  property :id
  property :name

  collection_representer class: Entity

  def completed
    represented.certificate.present?
  end
end
