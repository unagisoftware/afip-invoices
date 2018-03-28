class CreateInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoices do |t|
      t.references :entity, index: true, foreign_key: true
      t.date :emission_date, null: false
      t.string :authorization_code, null: false
      t.string :receipt, null: false

      t.timestamps
    end
  end
end
