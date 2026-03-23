class GamificationService
  Result = Struct.new(:xp_gained, :unlocked_achievements, keyword_init: true)

  def self.call(user, item)
    new(user, item).call
  end

  def self.item_completed!(user, item)
    call(user, item)
  end

  def initialize(user, item)
    @user = user
    @item = item
    @profile = user.gamification_profile
    @unlocked_achievements = []
  end

  def call
    return Result.new(xp_gained: 0, unlocked_achievements: []) unless @profile
    return Result.new(xp_gained: 0, unlocked_achievements: []) unless @item.completed?

    xp_before = @profile.xp

    ActiveRecord::Base.transaction do
      xp_gained = calculate_xp
      update_streak
      reward_xp(xp_gained)
      check_achievements
    end

    total_xp_gained = @profile.xp - xp_before
    Result.new(xp_gained: total_xp_gained, unlocked_achievements: @unlocked_achievements)
  end

  private

  def calculate_xp
    xp = @item.xp_value
    xp += 5 if completed_on_time?
    xp += 30 if task_list_completed?
    xp
  end

  def completed_on_time?
    return false unless @item.due_date
    Date.current <= @item.due_date
  end

  def task_list_completed?
    @item.task_list.complete?
  end

  def update_streak
    today = Date.current
    last_activity = @profile.last_activity_date

    if last_activity == today
      # Already active today, do nothing to streak
    elsif last_activity == today - 1.day
      # Active yesterday, increment streak
      @profile.streak_days += 1
      @profile.max_streak = [@profile.max_streak, @profile.streak_days].max
      @profile.last_activity_date = today
      @profile.xp += 10 # +10 XP for daily streak
    else
      # Missed a day or first activity, reset streak
      @profile.streak_days = 1
      @profile.max_streak = [@profile.max_streak, 1].max
      @profile.last_activity_date = today
      @profile.xp += 10 # +10 XP for daily streak
    end
  end

  def reward_xp(amount)
    @profile.xp += amount
    @profile.recalculate_level!
    @profile.save!
  end

  def check_achievements
    completed_items_count = Item.joins(:task_list)
                                .where(task_lists: { user_id: @user.id })
                                .completed
                                .count

    unlock_achievement('first_task') if completed_items_count >= 1
    unlock_achievement('task_10') if completed_items_count >= 10
    unlock_achievement('task_50') if completed_items_count >= 50
    unlock_achievement('task_100') if completed_items_count >= 100

    unlock_achievement('high_priority') if @item.high?

    unlock_achievement('streak_3') if @profile.streak_days >= 3
    unlock_achievement('streak_7') if @profile.streak_days >= 7

    unlock_achievement('level_2') if @profile.level >= 2
    unlock_achievement('level_5') if @profile.level >= 5
    
    # Also for first list, but the item completion implies the user already has a list, 
    # so we might as well award it if they don't have it yet:
    unlock_achievement('first_list') if @user.task_lists.any?
  end

  def unlock_achievement(key)
    achievement = Achievement.find_by(key: key)
    return unless achievement
    
    return if @user.user_achievements.exists?(achievement: achievement)

    UserAchievement.create!(
      user: @user,
      achievement: achievement,
      earned_at: Time.current
    )

    @unlocked_achievements << achievement

    if achievement.xp_reward.to_i > 0
      @profile.xp += achievement.xp_reward
      @profile.recalculate_level!
      @profile.save!
    end
  end
end
