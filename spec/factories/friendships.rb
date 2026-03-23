FactoryBot.define do
  factory :friendship do
    association :user
    association :friend, factory: :user

    trait :pending do
      status { :pending }
    end

    trait :accepted do
      status { :accepted }
    end
  end
end
