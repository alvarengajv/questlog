class Item < ApplicationRecord
  belongs_to :task_list

  enum :status, { pending: 0, completed: 1 }
end
