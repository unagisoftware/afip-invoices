class AddNullConstraintsToEntity < ActiveRecord::Migration[5.1]
  def change
    change_column_null :entities, :private_key, true
    change_column_null :entities, :cuit, true
    change_column_null :entities, :name, true
    change_column_null :entities, :business_name, true
    change_column_null :entities, :csr, true
  end
end
