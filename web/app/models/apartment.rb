class Apartment < ApplicationRecord
  belongs_to :realtor, class_name: 'User', foreign_key: 'realtor_id'

  validates :name, presence: true, allow_blank: false
  validates :description, presence: true, allow_blank: false
  validates :floor_area_size, presence: true
  validates :price_per_month, presence: true
  validates :number_of_rooms, presence: true
  validates :lat, presence: true, :inclusion => -90..90
  validates :lon, presence: true, :inclusion => -180..180

  validate :realtor_valid

  def to_json
    {
      name: self.name, floorAreaSize: self.floor_area_size.to_f, pricePerMonth: (self.price_per_month.to_f / 100.0),
      lat: lat.to_f, lon: lon.to_f, numberOfRooms: number_of_rooms, description: description, rented: rented, id: id,
      realtor: self.realtor.nil? ? nil : self.realtor.email
    }
  end

  private

  def realtor_valid
    user = User.find_by_id(self.realtor_id)
    if user.nil? || !user.realtor?
      self.errors.add(:base, "Realtor is not valid")
    end
  end
end
