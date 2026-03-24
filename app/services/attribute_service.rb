class AttributeService
  # Returns { "List Name" => points, ... } for all active task_lists of the user.
  # Points = sum of xp_value (low=5, medium=10, high=20) for completed items.
  # Lists without completed items appear with 0.
  # Archived lists are excluded.
  # Uses a single query with LEFT JOIN, GROUP BY, and SUM(CASE).
  def self.scores_for(user)
    lists_with_scores = user.task_lists
      .where(status: :active)
      .left_joins(:items)
      .group("task_lists.id", "task_lists.title")
      .pluck(
        Arel.sql("task_lists.title"),
        Arel.sql(<<~SQL.squish)
          COALESCE(SUM(
            CASE WHEN items.status = 1 THEN
              CASE items.priority
                WHEN 0 THEN 5
                WHEN 1 THEN 10
                WHEN 2 THEN 20
                ELSE 0
              END
            ELSE 0
            END
          ), 0)
        SQL
      )

    lists_with_scores.to_h
  end

  # Normalizes scores to 0-100 scale.
  # Highest value becomes 100, others proportional.
  # If all values are 0, returns all 0.
  def self.normalize(scores)
    max = scores.values.max || 0
    return scores.transform_values { 0 } if max.zero?

    scores.transform_values { |v| (v * 100.0 / max).round }
  end
end
