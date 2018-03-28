# frozen_string_literal: true

module V1
  class StaticController < ApplicationController
    def bill_types
      render json: StaticResource::BillTypes.new(entity).call
    end

    def concept_types
      render json: StaticResource::ConceptTypes.new(entity).call
    end

    def currencies
      render json: StaticResource::Currencies.new(entity).call
    end

    def document_types
      render json: StaticResource::DocumentTypes.new(entity).call
    end

    def iva_types
      render json: StaticResource::IvaTypes.new(entity).call
    end

    def sale_points
      render json: StaticResource::SalePoints.new(entity).call
    end

    def tax_types
      render json: StaticResource::TaxTypes.new(entity).call
    end

    def optionals
      render json: StaticResource::Optionals.new(entity).call
    end

    # rubocop:disable Naming/PredicateName
    def is_working
      head :ok
    end
    # rubocop:enable Naming/PredicateName
  end
end
