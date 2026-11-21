FactoryBot.define do
  factory :album_collaborator do
    association :album
    association :user
    association :invited_by, factory: :user
    role { "editor" }
  end
end