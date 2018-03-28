# frozen_string_literal: true

module Afip
  class BaseError < RuntimeError
    ERROR = 'Error de conexión con AFIP'

    def initialize(error)
      super("#{ERROR}: #{error}.")
    end

    private

    def logger
      @logger ||= Loggers::AfipConnection.new(json: true)
    end
  end
end
