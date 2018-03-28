# frozen_string_literal: true

module V1
  class AfipPeopleController < ApplicationController
    def show
      render json: Afip::Person.new(person_params, entity).info
    end

    private

    def person_params
      params.permit(:cuit)
    end
  end
end
