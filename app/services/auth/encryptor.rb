# frozen_string_literal: true

module Auth
  class Encryptor
    KEY = ActiveSupport::KeyGenerator.new(
      ENV.fetch('SECRET_KEY_BASE'),
    ).generate_key(
      ENV.fetch('ENCRYPTION_SERVICE_SALT'),
      ActiveSupport::MessageEncryptor.key_len,
    ).freeze

    delegate :encrypt_and_sign, :decrypt_and_verify, to: :encryptor

    def self.encrypt(data)
      new.encrypt_and_sign(data)
    end

    def self.decrypt(data)
      new.decrypt_and_verify(data)
    end

    private

    def encryptor
      ActiveSupport::MessageEncryptor.new(KEY)
    end
  end
end
