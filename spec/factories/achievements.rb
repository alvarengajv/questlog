FactoryBot.define do
  factory :achievement do
    sequence(:key) { |n| "achievement_#{n}" }
    sequence(:name) { |n| "Achievement #{n}" }
    description { "A great achievement" }
    xp_reward { 50 }
  end
end
