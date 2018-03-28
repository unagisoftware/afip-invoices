# frozen_string_literal: true

module Afip
  class Person
    attr_reader :afip, :params

    def initialize(params, entity)
      @afip   = Afip::PeopleService.new(entity)
      @params = params
    end

    def info
      response = afip.call(:get_persona, message)
      response = response[:get_persona_response][:persona_return]

      raise_response_error(response) if response[:error_constancia].present?

      represent_person(response)
    end

    private

    def message
      { 'idPersona' => params[:cuit] }
    end

    def represent_person(response)
      AfipPersonRepresenter.new(data: response)
    end

    def raise_response_error(response)
      error_message = Array
        .wrap(response[:error_constancia][:error])
        .join('. ')

      raise Afip::ResponseError.new(
        error_message: error_message,
        message: message,
        response: response,
      )
    end
  end
end
