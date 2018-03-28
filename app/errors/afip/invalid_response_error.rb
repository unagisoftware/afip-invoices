# frozen_string_literal: true

module Afip
  class InvalidResponseError < BaseError
    def initialize(error:, message:, response:)
      error_message = 'respuesta de servidor inválida'

      logger.error(
        backtrace: error.backtrace,
        message: error_message,
        parameters: message,
        response: response,
      )

      super(error_message)
    end
  end
end
