class LeaderboardsController < ApplicationController
  before_action :require_authentication

  def show
    @rankings = User.joins(:gamification_profile)
                     .select("users.id, users.name, gamification_profiles.level, gamification_profiles.xp, gamification_profiles.streak_days")
                     .order("gamification_profiles.xp DESC")
    @current_user_id = current_user.id
  end
end
