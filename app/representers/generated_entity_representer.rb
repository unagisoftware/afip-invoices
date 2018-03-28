# frozen_string_literal: true

class GeneratedEntityRepresenter < Representable::Decorator
  include Representable::JSON

  property :business_name
  property :csr
  property :cuit
  property :id
  property :name

  collection_representer class: Entity
end
