class ProfilesController < ApplicationController
  before_action :require_authentication

  def show
    @profile = current_user.gamification_profile
    @recent_achievements = current_user.achievements.order('user_achievements.created_at DESC').limit(3)
  end

  def achievements
    @profile = current_user.gamification_profile
    @all_achievements = Achievement.order(:xp_reward)
    @user_achievement_ids = current_user.achievement_ids
  end
end
