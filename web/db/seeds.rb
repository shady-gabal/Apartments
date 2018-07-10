# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!({
  name: "Shady Gabal",
  email: "shadygabal@gmail.com",
  password: "12345678",
  id: 1
            })

Apartment.create!({
  name: "Great Fake Apartment",
  description: "Here's a really nice fake apartment in the middle of nowhere",
  floor_area_size: 5000,
  price_per_month: 1000,
  number_of_rooms: 2,
  lat: 40.232,
  lon: -74.903,
  realtor_id: 1
                 })

Apartment.create!({
                   name: "Apartment Number 2",
                   description: "A really crappy apartment.",
                   floor_area_size: 300,
                   price_per_month: 100,
                   number_of_rooms: 1,
                   lat: 45.932,
                   lon: -71.903,
                   realtor_id: 1
                 })
