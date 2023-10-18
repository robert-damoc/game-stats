FactoryBot.define do
  factory :player do
    name { Faker::Name.first_name[...30] }
  end
end
