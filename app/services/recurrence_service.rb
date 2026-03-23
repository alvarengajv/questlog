class RecurrenceService
  def self.process!(item)
    return nil unless item.completed? && item.recurring?

    next_occurrence = calculate_next_occurrence(item)
    next_occurrence
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
