# frozen_string_literal: true

module Afip
  class ResponseError < BaseError
    def initialize(error_message:, message:, response:)
      logger.error(
        message: error_message,
        parameters: message,
        response: response,
      )

      super(error_message)
    end
  end
end
