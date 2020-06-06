require 'faker'

FactoryGirl.define do
  factory :list do
    name "MyString"
    url "MyString"
  end

  factory :reason_category do
    name "MyString"
  end

  factory :beta_email do

  end

  factory :comment do
    text "MyText"
    association :statement, factory: :statement
    association :individual, factory: :individual
  end

  factory :email do
    email "MyString"
  end

  factory :statement do
    content { Faker::Lorem.sentence }
  end

  factory :individual do
    name { Faker::Name.name }
    twitter { Faker::Internet.user_name }
    followers_count { 5 }
  end

  factory :agreement do
    url { Faker::Internet.url }
    reason { Faker::Lorem.sentence }
    association :statement, factory: :statement
    association :individual, factory: :individual
  end

  factory :profession do
    name { Faker::Name.name }
  end
end
