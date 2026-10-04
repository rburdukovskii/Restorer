FactoryBot.define do
  factory :upload do
    user
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    favorite { false }
    status { "pending" }
    progress { 0 }

    after(:build) do |upload|
      if upload.original.blank?
        upload.original.attach(
          io: File.open(Rails.root.join("test/fixtures/files/demo.jpg")),
          filename: "demo.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    trait :completed do
      status { "completed" }
      progress { 100 }

      after(:build) do |upload|
        upload.processed.attach(
          io: File.open(Rails.root.join("test/fixtures/files/demo.jpg")),
          filename: "demo_processed.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    trait :favorite do
      favorite { true }
    end
  end
end