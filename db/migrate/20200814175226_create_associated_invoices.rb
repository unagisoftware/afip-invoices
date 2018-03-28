class CreateAssociatedInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :associated_invoices do |t|
      t.string :receipt, null: false
      t.date :emission_date, null: false
      t.integer :bill_type_id, null: false
      t.references :invoice, index: true, null: false, foreign_key: true

      t.timestamps
    end
  end
end
