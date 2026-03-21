class GamificationProfile < ApplicationRecord
  belongs_to :user

  LEVELS = {
    1 => 0,
    2 => 100,
    3 => 300,
    4 => 600,
    5 => 1000
  }.freeze

  validates :level, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :xp, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :streak_days, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def recalculate_level!
    new_level = LEVELS.keys.reverse.find { |l| xp >= LEVELS[l] } || 1
    update!(level: new_level) if level != new_level
  end

  def xp_progress_percentage
    return 100 if level >= LEVELS.keys.max

    current_level_xp = LEVELS[level]
    next_level_xp = LEVELS[level + 1]

    xp_into_level = xp - current_level_xp
    xp_required = next_level_xp - current_level_xp

    ((xp_into_level.to_f / xp_required) * 100).round
  end
end
