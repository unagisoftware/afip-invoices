class AddIvaAliquotToInvoiceItems < ActiveRecord::Migration[5.1]
  def change
    add_column :invoice_items,
      :iva_aliquot,
      :decimal,
      precision: 5,
      scale: 2,
      null: true

    InvoiceItem.where(iva_aliquot: nil).update_all(iva_aliquot: 0.0)

    change_column_null :invoice_items, :iva_aliquot, false
  end
end
