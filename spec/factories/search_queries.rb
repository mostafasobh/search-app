FactoryBot.define do
  factory :search_query do
    sequence(:query) { |n| "query_#{n}" }
    association :user
  end
end
