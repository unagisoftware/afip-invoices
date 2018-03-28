# frozen_string_literal: true

module Afip
  class TimeoutError < BaseError
    ERROR_MESSAGE = 'timeout de conexión con AFIP'

    def initialize
      logger.error(message: ERROR_MESSAGE)

      super(ERROR_MESSAGE)
    end
  end
end
