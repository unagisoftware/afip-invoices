# frozen_string_literal: true

class Invoice
  class RecipientLoaderSupport
    RECIPIENT_FORMAT = {
      'address' => String,
      'category' => String,
      'city' => String,
      'full_address' => String,
      'name' => String,
      'state' => String,
      'zipcode' => String,
    }.freeze
  end
end
