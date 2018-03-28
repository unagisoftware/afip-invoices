class AddIndexToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_index :invoices, [:bill_type_id, :receipt]
  end
end
