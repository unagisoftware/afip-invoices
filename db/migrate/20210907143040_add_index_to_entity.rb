class AddIndexToEntity < ActiveRecord::Migration[6.1]
  def change
    add_index :entities, :business_name, unique: true
    add_index :entities, :cuit, unique: true
  end
end
