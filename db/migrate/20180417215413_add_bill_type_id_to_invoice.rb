class AddBillTypeIdToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :bill_type_id, :integer, null: false
  end
end
