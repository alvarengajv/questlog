class LeaderboardsController < ApplicationController
  before_action :require_authentication

  def show
    friend_ids = current_user.friendships.accepted.pluck(:friend_id)
    user_ids = friend_ids + [ current_user.id ]

    @rankings = User.joins(:gamification_profile)
                     .where(id: user_ids)
                     .select("users.id, users.name, gamification_profiles.level, gamification_profiles.xp, gamification_profiles.streak_days")
                     .order("gamification_profiles.xp DESC")
    @current_user_id = current_user.id
  end
end
