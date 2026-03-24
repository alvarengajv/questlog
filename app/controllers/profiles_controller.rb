class ProfilesController < ApplicationController
  before_action :require_authentication

  def show
    @profile = current_user.gamification_profile
    @recent_achievements = current_user.achievements.order('user_achievements.created_at DESC').limit(3)
    @total_tasks = Item.where(task_list: current_user.task_lists).completed.count
    @attribute_scores = AttributeService.scores_for(current_user)
    @attribute_scores_normalized = AttributeService.normalize(@attribute_scores)
  end

  def achievements
    @profile = current_user.gamification_profile
    @all_achievements = Achievement.order(:xp_reward)
    @user_achievement_ids = current_user.achievement_ids
    @unlock_dates = current_user.user_achievements.each_with_object({}) do |ua, hash|
      hash[ua.achievement_id] = ua.earned_at
    end
  end
end
