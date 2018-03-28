# frozen_string_literal: true

namespace :credentials_generator do
  desc 'Generate AUTH_TOKEN to paste in your env file'
  task auth_token: :environment do
    token = SecureRandom.hex(12)

    print_instructions('AUTH_TOKEN', token)
  end

  desc 'Generate ENCRYPTION_SERVICE_SALT to paste in your env file'
  task salt_encryptor: :environment do
    salt = SecureRandom.random_bytes(ActiveSupport::MessageEncryptor.key_len)

    print_instructions('ENCRYPTION_SERVICE_SALT', salt)
  end

  private

  def print_instructions(env_var_name, env_var_value)
    puts ''"Replace or update #{env_var_name} env var

    In your application.yml

    #{env_var_name}: #{env_var_value.inspect}

    In your .env (with Docker)

    #{env_var_name}=#{env_var_value.inspect}"''
  end
end
