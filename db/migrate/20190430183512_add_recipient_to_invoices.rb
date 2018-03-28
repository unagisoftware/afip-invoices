class AddRecipientToInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :recipient, :jsonb
  end
end
