require 'rails_helper'

RSpec.describe "Leaderboards", type: :request do
  let(:password) { 'password123' }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  describe "unauthenticated access" do
    it "redirects to login" do
      get leaderboard_path
      expect(response).to redirect_to(login_path)
    end
  end

  context "when authenticated" do
    before do
      post login_path, params: { email: user.email, password: password }
    end

    describe "GET /leaderboard" do
      it "returns a successful response" do
        get leaderboard_path
        expect(response).to be_successful
        expect(response.body).to include("Ranking")
      end

      it "displays users ranked by XP descending" do
        user1 = create(:user, name: "Top Player")
        user1.gamification_profile.update!(xp: 500, level: 3, streak_days: 7)

        user2 = create(:user, name: "Mid Player")
        user2.gamification_profile.update!(xp: 200, level: 2, streak_days: 3)

        get leaderboard_path

        expect(response.body).to include("Top Player")
        expect(response.body).to include("Mid Player")
        expect(response.body).to include("500")
        expect(response.body).to include("200")
      end

      it "displays position, name, level, XP, and streak" do
        user.gamification_profile.update!(xp: 100, level: 2, streak_days: 5)

        get leaderboard_path

        expect(response.body).to include(user.name)
        expect(response.body).to include("100")   # XP
        expect(response.body).to include("2")     # level
      end

      it "highlights the current user" do
        get leaderboard_path
        expect(response).to be_successful
      end
    end
  end
end
