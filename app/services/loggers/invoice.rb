# frozen_string_literal: true

module Loggers
  class Invoice
    def initialize(name = 'invoice', json: false)
      @logfile_debug = Logger.new("log/#{name}_debug.log")
      @logfile_error = Logger.new("log/#{name}_error.log")
      @json = json
    end

    def debug(action:, message: nil, data: nil)
      msg = {
        action: action,
        message: message,
        data: data,
      }

      msg = msg.to_json if @json

      @logfile_debug.info(msg)
    end

    def error(message:, parameters: nil, response: nil, code: nil)
      msg = {
        code: code,
        message: message,
        parameters: parameters,
        response: response,
      }

      msg = msg.to_json if @json

      @logfile_error.error(msg)
    end
  end
end
