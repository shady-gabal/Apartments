# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


def random_string(approx_len)
  step = approx_len > 20 ? 5 : 1
  ans = ""
  while ans.length < approx_len
    ans += ('a'..'z').to_a.shuffle[0,step].join
  end

  ans
end

client_ids = []
realtor_ids = []

5.times do |t|
  u = User.create!({
                 name: random_string(Random.new.rand(5..30)),
                 email: "#{random_string(Random.new.rand(2..10))}@gmail.com",
                 password: "12345678",
                 role: User::Role::CLIENT
               })
  client_ids << u.id
end

5.times do |t|
  u = User.create!({
                     name: random_string(Random.new.rand(5..30)),
                     email: "#{random_string(Random.new.rand(2..10))}@gmail.com",
                     password: "12345678",
                     role: User::Role::REALTOR
                   })
  realtor_ids << u.id
end


50.times do |num|
  Apartment.create!({
                      name: random_string(Random.new.rand(3..40)),
                      description: random_string(Random.new.rand(10..100)),
                      floor_area_size: Random.new.rand(1..3000),
                      price_per_month: Random.new.rand(1..700000).to_i,
                      number_of_rooms: Random.new.rand(1..10).to_i,
                      lat: Random.new.rand(-90..90),
                      lon: Random.new.rand(-180..180),
                      realtor_id: realtor_ids.sample,
                      rented: Random.new.rand(0..1)
                    })
end