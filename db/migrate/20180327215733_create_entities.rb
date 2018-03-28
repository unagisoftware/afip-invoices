class CreateEntities < ActiveRecord::Migration[5.1]
  def change
    create_table :entities do |t|
      t.text :certificate
      t.text :private_key
      t.text :csr
      t.string :cuit
      t.string :name
      t.string :business_name

      t.timestamps
    end
  end
end
