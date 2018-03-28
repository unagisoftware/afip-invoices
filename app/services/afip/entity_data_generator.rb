# frozen_string_literal: true

module Afip
  class EntityDataGenerator
    def initialize(entity)
      @entity = entity
    end

    def call
      key = OpenSSL::PKey::RSA.new(8192)
      csr = build_csr(key)

      {
        subject: csr_subject,
        pkey: key.to_pem,
        csr: csr,
      }
    end

    private

    def build_csr(key)
      csr = OpenSSL::X509::Request.new

      csr.version = 0
      csr.subject = OpenSSL::X509::Name.parse(csr_subject)
      csr.public_key = key.public_key

      csr.sign(key, OpenSSL::Digest.new('SHA1'))

      csr
    end

    def csr_subject
      "/C=AR/O=#{@entity.name}/CN=Unagi/serialNumber=CUIT #{@entity.cuit}"
    end
  end
end
