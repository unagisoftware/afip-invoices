# frozen_string_literal: true

require_relative '../services/afip/person_support'

class AfipPeopleControllerSupport
  RESPONSE_FORMAT = Afip::PersonSupport::RESPONSE_FORMAT.dup.freeze
end
