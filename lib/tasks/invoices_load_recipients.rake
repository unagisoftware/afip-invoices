# frozen_string_literal: true

namespace :invoices do
  desc "Load missing invoices' recipients"
  task load_recipients: :environment do
    Invoice.all.where(recipient: nil).includes(:entity).each do |invoice|
      LoadRecipientIntoInvoice.new(invoice).call!
    end
  end
end
