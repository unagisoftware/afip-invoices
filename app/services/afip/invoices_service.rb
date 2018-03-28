# frozen_string_literal: true

module Afip
  class InvoicesService < Middleware
    ENDPOINT = ENV['WSFE_URL']
    SERVICE  = 'wsfe'

    private

    def auth_params
      {
        'Auth' => {
          'Token' => token,
          'Sign' => sign,
          'Cuit' => entity_cuit,
        },
      }
    end

    def endpoint
      ENDPOINT
    end

    def service
      SERVICE
    end
  end
end
