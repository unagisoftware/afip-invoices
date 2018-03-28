# frozen_string_literal: true

module StaticResource
  class Base
    TTL = 12.hours

    def initialize(entity)
      @entity = entity
      @afip = Afip::InvoicesService.new(entity)
    end

    def call
      return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

      response = format_response @afip.call(operation)

      return response if response.is_a?(Hash) && response.key?(:error)

      Rails.cache.write(cache_key, response, expires_in: TTL)
      response
    end

    def find(id)
      record = call.find { |type| type[:id].to_i == id.to_i }

      return nil unless record

      record[:name]
    rescue Afip::BaseError
      false
    end

    private

    def operation
      raise NotImplementedError
    end

    def resource
      raise NotImplementedError
    end

    def format_response(response)
      results = response["#{operation}_response".to_sym]["#{operation}_result".to_sym]

      return error_response(results[:errors]) if results[:errors]

      resources = Array.wrap(results[:result_get][resource])

      resources.map! { |item| format_item(item) }

      resources.compact
    end

    def format_item(item)
      { id: item[:id], name: item[:desc] }
    end

    def error_response(errors)
      { error: errors[:err][:msg] }
    end

    def cache_key
      "#{@entity.cuit}/#{operation}"
    end
  end
end
