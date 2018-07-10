class AddFieldsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :role, :string, default: User::Role::CLIENT
  end
end
