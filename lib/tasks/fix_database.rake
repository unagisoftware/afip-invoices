# frozen_string_literal: true

namespace :fix_database do
  desc 'Encrypt auth_token on existing entities'
  task encrypt_auth_tokens: :environment do
    Entity.all.each do |entity|
      original_token = entity.read_attribute(:auth_token)
      entity.auth_token = original_token
      entity.save
    end
  end
end
