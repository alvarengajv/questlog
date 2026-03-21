class AddPositionToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :position, :integer
  end
end
