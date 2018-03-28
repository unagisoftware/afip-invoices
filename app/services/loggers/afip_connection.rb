# frozen_string_literal: true

module Loggers
  class AfipConnection
    def initialize(name = 'afip', json: false)
      @logfile = Logger.new("log/#{name}_error.log")
      @json = json
    end

    def error(message:, backtrace: nil, http_status_code: nil, parameters: nil, response: nil)
      msg = {
        backtrace: backtrace,
        http_status_code: http_status_code,
        message: message,
        parameters: parameters,
        response: response,
      }

      msg = msg.to_json if @json

      @logfile.error(msg)
    end
  end
end
