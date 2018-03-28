class CreateAfipRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :afip_requests do |t|
      t.integer :bill_type_id, null: false
      t.bigint :invoice_id_client, null: false
      t.integer :sale_point_id, null: false
      t.string :bill_number, null: false
      t.references :entity, foreign_key: true, null: false
      t.timestamps
    end

    add_index :afip_requests, :invoice_id_client
  end
end
