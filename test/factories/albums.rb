FactoryBot.define do
  factory :album do
    user
    name { Faker::Lorem.words(number: 2).join(" ").titleize }
    description { Faker::Lorem.paragraph }
  end
end