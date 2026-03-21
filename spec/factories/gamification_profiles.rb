FactoryBot.define do
  factory :gamification_profile do
    association :user
    level { 1 }
    xp { 0 }
    streak_days { 0 }
    last_activity_date { Date.today }
  end
end
