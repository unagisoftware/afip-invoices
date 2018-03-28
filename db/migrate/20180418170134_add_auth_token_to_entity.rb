class AddAuthTokenToEntity < ActiveRecord::Migration[5.1]
  def change
    add_column :entities, :auth_token, :string
  end
end
