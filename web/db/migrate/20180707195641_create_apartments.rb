class CreateApartments < ActiveRecord::Migration[5.1]
  def change
    create_table :apartments do |t|
      t.string :name
      t.text :description
      t.decimal :floor_area_size
      t.integer :price_per_month
      t.integer :number_of_rooms
      t.decimal :lat
      t.decimal :lon

      t.timestamps
    end
  end
end
