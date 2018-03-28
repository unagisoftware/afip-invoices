class AddLogoUrlToInvoice < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :logo_url, :string
  end
end
