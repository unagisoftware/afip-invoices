# frozen_string_literal: true

module Afip
  class InvalidRequestError < BaseError
    def initialize(error:, http_status_code:, message:, response:)
      error_message = "solicitud inválida con error '#{error}'"

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
