# frozen_string_literal: true

module Encryptable
  extend ActiveSupport::Concern

  class_methods do
    def attr_encrypted(*attributes)
      attributes.each do |attribute|
        define_method("#{attribute}=".to_sym) do |value|
          return if value.nil?

          public_send(
            :write_attribute,
            attribute.to_sym,
            Auth::Encryptor.encrypt(value),
          )
        end

        define_method(attribute) do
          value = public_send(:read_attribute, attribute.to_sym)
          Auth::Encryptor.decrypt(value) if value.present?
        end
      end
    end
  end
end
