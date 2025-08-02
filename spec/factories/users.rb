FactoryBot.define do
  factory :user do
    ip { Faker::Internet.ip_v4_address }
  end
end
