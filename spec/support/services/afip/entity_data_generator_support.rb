# frozen_string_literal: true

module Afip
  class EntityDataGeneratorSupport
    RESPONSE_FORMAT = {
      csr: OpenSSL::X509::Request,
      pkey: String,
      subject: String,
    }.freeze
  end
end
