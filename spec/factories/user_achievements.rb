FactoryBot.define do
  factory :user_achievement do
    association :user
    association :achievement
    earned_at { Time.current }
  end
end
