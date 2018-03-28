class CreateInvoiceItems < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_items do |t|
      t.string :code
      t.string :name, null: false
      t.float :quantity, null: false, default: 1.0
      t.float :unit_price, null: false, default: 0.0
      t.float :bonus_percentage, null: false, default: 0.0
      t.string :metric_unit, null: false, default: 'unidades'
      t.references :invoice, index: true, foreign_key: true

      t.timestamps
    end
  end
end
