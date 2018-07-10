class Apartment < ApplicationRecord
  belongs_to :realtor, class_name: 'User', foreign_key: 'realtor_id'

  validates :name, presence: true, allow_blank: false
  validates :description, presence: true, allow_blank: false
  validates :floor_area_size, presence: true
  validates :price_per_month, presence: true
  validates :number_of_rooms, presence: true
  validates :lat, presence: true
  validates :lon, presence: true
end
