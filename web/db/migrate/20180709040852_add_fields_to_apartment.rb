class AddFieldsToApartment < ActiveRecord::Migration[5.1]
  def change
    add_column :apartments, :rented, :boolean, default: false
    add_column :apartments, :realtor_id, :integer, index: true
  end
end
