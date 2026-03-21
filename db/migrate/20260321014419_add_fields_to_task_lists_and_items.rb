class AddFieldsToTaskListsAndItems < ActiveRecord::Migration[8.1]
  def change
    add_column :task_lists, :color, :string
    add_column :task_lists, :status, :integer, default: 0
    add_column :items, :status, :integer, default: 0
  end
end
