# frozen_string_literal: true

module Afip
  class UnexpectedError < BaseError
    ERROR_MESSAGE = 'error no esperado'

    def initialize(error:)
      logger.error(
        backtrace: error.backtrace,
        message: error.message,
      )

      super(ERROR_MESSAGE)
    end
  end
end
