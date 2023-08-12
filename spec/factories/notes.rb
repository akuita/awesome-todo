FactoryBot.define do
  factory :note do
    title { Faker::Lorem.paragraph_by_chars(number: 255) }

    description { Faker::Lorem.paragraph_by_chars(number: 65_535) }
  end
end
