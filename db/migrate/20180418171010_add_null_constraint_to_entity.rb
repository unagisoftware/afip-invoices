class AddNullConstraintToEntity < ActiveRecord::Migration[5.1]
  def change
    change_column_null :entities, :auth_token, true
  end
end
