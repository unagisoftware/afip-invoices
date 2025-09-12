# frozen_string_literal: true

module Afip
  class PeopleService < Middleware
    ENDPOINT = ENV['PADRON_A5_URL']
    SERVICE  = 'ws_sr_padron_a5'

    private

    def auth_params
      {
        'token' => token,
        'sign' => sign,
        'cuitRepresentada' => entity_cuit,
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
