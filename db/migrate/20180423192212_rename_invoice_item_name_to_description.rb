class RenameInvoiceItemNameToDescription < ActiveRecord::Migration[5.1]
  def change
    rename_column :invoice_items, :name, :description
  end
end
