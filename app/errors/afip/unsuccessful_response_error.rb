# frozen_string_literal: true

module Afip
  class UnsuccessfulResponseError < BaseError
    def initialize(error:, http_status_code:, message:, response:)
      error_message = "respuesta no exitosa (HTTP #{http_status_code}) con error '#{error.message}'"

      logger.error(
        backtrace: error.backtrace,
        http_status_code: http_status_code,
        message: error_message,
        parameters: message,
        response: response,
      )

      super(error_message)
    end
  end
end
