class AddColumnsToEntities < ActiveRecord::Migration[5.1]
  def change
    add_column :entities, :condition_against_iva, :string
    add_column :entities, :activity_start_date, :date
    add_column :entities, :comertial_address, :string
    add_column :entities, :iibb, :string
  end
end