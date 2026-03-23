FactoryBot.define do
  factory :gamification_profile do
    user { association(:user) }
    level { 1 }
    xp { 0 }
    streak_days { 0 }
    last_activity_date { Date.today }

    to_create do |instance|
      existing = GamificationProfile.find_by(user_id: instance.user_id)
      if existing
        existing.update!(
          level: instance.level,
          xp: instance.xp,
          streak_days: instance.streak_days,
          last_activity_date: instance.last_activity_date
        )
        existing
      else
        instance.save!
        instance
      end
    end
  end
end
