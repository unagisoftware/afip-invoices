class UpdateColumnOfInvoiceItem < ActiveRecord::Migration[5.1]
  def change
    change_column_null :invoice_items, :metric_unit, true
  end
end
