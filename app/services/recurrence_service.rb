class RecurrenceService
  def self.call(item)
    return nil unless item.completed? && item.recurring?

    next_due_date = calculate_next_occurrence(item)

    item.task_list.items.create!(
      content: item.content,
      priority: item.priority,
      recurrence: item.recurrence,
      due_date: next_due_date,
      status: :pending
    )
  end

  def self.calculate_next_occurrence(item)
    base_date = item.due_date || Date.current

    case item.recurrence
    when "daily"
      base_date + 1.day
    when "weekly"
      base_date + 1.week
    when "monthly"
      base_date + 1.month
    end
  end
end
