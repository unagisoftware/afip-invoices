class ChangeIvaAliquotInInvoiceItems < ActiveRecord::Migration[5.1]
  ID_FROM_RATE = {
    0.0  => 3,
    2.5  => 9,
    5.0  => 8,
    10.5 => 4,
    21.0 => 5,
    27.0 => 6
  }.freeze

  def up
    InvoiceItem.all.find_each do |item|
      id = ID_FROM_RATE[item.attributes['iva_aliquot'].to_f]

      unless id
        raise "No se encontró el ID asociado a la alícuota #{item.attributes['iva_aliquot']} del item #{item.id}"        
      end

      item.update(iva_aliquot: id)
    end

    change_column :invoice_items, :iva_aliquot, :integer
    rename_column :invoice_items, :iva_aliquot, :iva_aliquot_id
  end

  def down
    change_column :invoice_items, :iva_aliquot_id, :decimal, precision: 5, scale: 2

    InvoiceItem.all.find_each do |item|
      rate = ID_FROM_RATE.key(item.iva_aliquot_id.to_i)

      unless rate
        raise "No se encontró la alícuota asociada al ID #{item.iva_aliquot_id} para el item #{item.id}"
      end

      item.update(iva_aliquot_id: rate)
    end

    rename_column :invoice_items, :iva_aliquot_id, :iva_aliquot
  end
end
