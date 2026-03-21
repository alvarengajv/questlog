class CreateGamificationProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :gamification_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :xp, default: 0, null: false
      t.integer :level, default: 1, null: false
      t.integer :streak_days, default: 0, null: false
      t.date :last_activity_date

      t.timestamps
    end
  end
end
