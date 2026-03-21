class CreateTaskLists < ActiveRecord::Migration[8.1]
  def change
    create_table :task_lists do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :title

      t.timestamps
    end
  end
end
