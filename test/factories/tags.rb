FactoryBot.define do
  factory :tag do
    user
    name { Faker::Lorem.word.downcase }
  end
end