class AddMaxStreakToGamificationProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :gamification_profiles, :max_streak, :integer, default: 0, null: false
  end
end
