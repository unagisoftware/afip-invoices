class AddOptionalColumnsToInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :cbu, :string
    add_column :invoices, :alias, :string
  end
end
