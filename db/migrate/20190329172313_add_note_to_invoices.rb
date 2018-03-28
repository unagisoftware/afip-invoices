class AddNoteToInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :note, :text
  end
end
