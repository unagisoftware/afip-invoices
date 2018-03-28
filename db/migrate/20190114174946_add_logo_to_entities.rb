class AddLogoToEntities < ActiveRecord::Migration[5.1]
  def change
    add_column :entities, :logo, :string
  end
end
