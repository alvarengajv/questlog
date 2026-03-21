class CreateAchievements < ActiveRecord::Migration[8.1]
  def change
    create_table :achievements do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :key, null: false
      t.integer :xp_reward, default: 0, null: false
      t.string :icon_url

      t.timestamps
    end
    add_index :achievements, :key, unique: true
  end
end
