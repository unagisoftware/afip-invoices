class AddTokenToInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :token, :string
    Invoice.all.each { |i| i.regenerate_token }

    change_column_null :invoices, :token, false
    add_index :invoices, :token, unique: true
  end
end
