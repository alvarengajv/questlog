class Item < ApplicationRecord
  belongs_to :task_list

  enum :status, { pending: 0, completed: 1 }
  enum :priority, { low: 0, medium: 1, high: 2 }
  enum :recurrence, { none_recurrence: 0, daily: 1, weekly: 2, monthly: 3 }

  # Scopes
  scope :completed, -> { where(status: :completed) }
  scope :pending, -> { where(status: :pending) }
  scope :by_priority, -> { order(priority: :desc) }

  def overdue?
    return false unless due_date
    due_date < Date.current && pending?
  end

  def due_today?
    return false unless due_date
    due_date == Date.current
  end

  def recurring?
    !none_recurrence?
  end

  def xp_value
    case priority
    when "low" then 5
    when "medium" then 10
    when "high" then 20
    else 0
    end
  end
end
