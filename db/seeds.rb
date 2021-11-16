# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'

companies = Array.new(3) do
    Company.create!(
        name: Faker::Company.unique.name,
        address: "#{Faker::Address.street_address}, #{Faker::Address.city}"
    )
end

parkings = Array.new(3) do
    Parking.create!(
        company: companies.sample,
        address: "#{Faker::Address.street_address}, #{Faker::Address.city}"
    )
end

30.times do
    Spot.create!(
        parking: parkings.sample,
        status: 0
    )
end