# frozen_string_literal: true

module Auth
  class TokenValidator
    TTL = 10.minutes.freeze

    def initialize(token)
      @token = token
    end

    def call
      Rails
        .cache
        .fetch(@token, expires_in: TTL) do
          Entity.all.find { |entity| entity.auth_token == @token }
        end
    end
  end
end
