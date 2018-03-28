# frozen_string_literal: true

module Afip
  class Middleware
    TTL         = 12.hours.freeze
    LOGIN_URL   = ENV['LOGIN_URL']
    BASIC_ERROR = 'Error de conexión con AFIP'

    attr_reader :token, :sign, :entity_cuit

    def initialize(entity)
      @afip_certificate = entity.certificate
      @afip_private_key = entity.private_key
      @entity_cuit      = entity.cuit

      fetch_or_create_token_and_sign
    end

    # rubocop:disable Metrics/MethodLength
    def call(operation, message = {})
      response = Savon
        .client(build_params)
        .call(operation, message: auth_params.merge(message))

      response.body
    rescue Savon::SOAPFault => e
      raise Afip::InvalidRequestError.new(
        http_status_code: e.http.code,
        error: e,
        response: response,
        message: message,
      )
    rescue Savon::HTTPError => e
      raise Afip::UnsuccessfulResponseError.new(
        http_status_code: e.http.code,
        error: e,
        message: message,
        response: response,
      )
    rescue Savon::InvalidResponseError => e
      raise Afip::InvalidResponseError.new(
        error: e,
        message: message,
        response: response,
      )
    rescue Net::ReadTimeout
      raise Afip::TimeoutError
    rescue StandardError => e
      raise Afip::UnexpectedError.new(error: e)
    end
    # rubocop:enable Metrics/MethodLength

    private

    # rubocop:disable Naming/VariableNumber
    def build_params
      {
        endpoint: endpoint,
        log: Rails.env.development?,
        open_timeout: 200,
        read_timeout: 200,
        ssl_version: :TLSv1_2,
        wsdl: wsdl,
      }
    end
    # rubocop:enable Naming/VariableNumber

    def auth_params
      raise NotImplementedError
    end

    def endpoint
      raise NotImplementedError
    end

    def service
      raise NotImplementedError
    end

    def wsdl
      "#{endpoint}?wsdl"
    end

    def fetch_or_create_token_and_sign
      access_token = Rails
        .cache
        .fetch("afip/#{@entity_cuit}/#{service}", expires_in: TTL) do
          create_token_and_sign
        end

      @token = access_token['credentials']['token']
      @sign = access_token['credentials']['sign']
    end

    # rubocop:disable Metrics/MethodLength
    def create_token_and_sign
      message = { in0: cms_params }
      # rubocop:disable Naming/VariableNumber
      response = Savon
        .client(wsdl: LOGIN_URL, ssl_version: :TLSv1_2)
        .call(:login_cms, message: message)
      # rubocop:enable Naming/VariableNumber
      data = response.hash[:envelope][:body][:login_cms_response][:login_cms_return]

      Hash.from_xml(data)['loginTicketResponse']
    rescue Savon::SOAPFault => e
      raise Afip::InvalidRequestError.new(
        error: e,
        http_status_code: e.http.code,
        message: message,
        response: response,
      )
    rescue Savon::HTTPError => e
      raise Afip::UnsuccessfulResponseError.new(
        error: e,
        http_status_code: e.http.code,
        message: message,
        response: response,
      )
    rescue Savon::InvalidResponseError => e
      raise Afip::InvalidResponseError.new(
        error: e,
        message: message,
        response: response,
      )
    rescue Net::ReadTimeout
      raise Afip::TimeoutError
    rescue StandardError => e
      raise Afip::UnexpectedError.new(error: e)
    end
    # rubocop:enable Metrics/MethodLength

    def cms_params
      request = Nokogiri::XML::Builder.new do |xml|
        xml.loginTicketRequest(version: 1) do
          xml.header do
            xml.uniqueId(Time.zone.now.to_i)
            xml.generationTime(formatted_datetime(Time.zone.now - TTL))
            xml.expirationTime(formatted_datetime(Time.zone.now + TTL))
          end
          xml.service(service)
        end
      end.to_xml

      OpenSSL::PKCS7.sign(
        OpenSSL::X509::Certificate.new(@afip_certificate),
        OpenSSL::PKey::RSA.new(@afip_private_key),
        request,
      ).to_pem.lines.to_a[1..-2].join
    end

    def formatted_datetime(time)
      time.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/(\d{2})(\d{2})$/, '\1:\2')
    end
  end
end
