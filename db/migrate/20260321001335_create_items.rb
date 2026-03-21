class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.references :task_list, null: false, foreign_key: { on_delete: :cascade }
      t.string :content
      t.integer :priority, default: 0
      t.integer :recurrence, default: 0

      t.timestamps
    end
  end
end
