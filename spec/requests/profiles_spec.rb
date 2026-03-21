require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }
  # The gamification profile is automatically created when user is created via the after_create callback
  let(:profile) { user.gamification_profile }
  
  before do
    # Create some achievements to test achievements view
    @achievement1 = create(:achievement, xp_reward: 10, name: "First Achievement")
    @achievement2 = create(:achievement, xp_reward: 20, name: "Second Achievement")
    @achievement3 = create(:achievement, xp_reward: 50, name: "Third Achievement")
  end

  describe "GET /profile" do
    context "when user is not authenticated" do
      it "redirects to the login page" do
        get profile_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when user is authenticated" do
      before do
        post login_path, params: { email: user.email, password: user.password }
        
        # Give user some stats and an achievement
        profile.update!(xp: 150, level: 2, streak_days: 5, max_streak: 10)
        create(:user_achievement, user: user, achievement: @achievement1)
        create(:user_achievement, user: user, achievement: @achievement2)
      end

      it "returns a successful response" do
        get profile_path
        expect(response).to be_successful
        expect(response.body).to include("Meu Perfil")
        expect(response.body).to include(user.email)
      end

      it "displays the user's gamification stats correctly" do
        get profile_path
        
        # Checking level, xp, streak, max_streak and title
        expect(response.body).to include("Novato") # title for level 2
        expect(response.body).to include("2") # level
        expect(response.body).to include("150") # XP
        expect(response.body).to include("5 🔥") # streak
        expect(response.body).to include("10 🏆") # max streak
      end
      
      it "displays recent achievements" do
        get profile_path

        expect(response.body).to include("First Achievement")
        expect(response.body).to include("Second Achievement")
        # Should not include unlocked achievements in the recent list? 
        # Actually it only shows unlocked achievements in recent, so @achievement3 is not there
        expect(response.body).not_to include("Third Achievement")
      end
    end
  end

  describe "GET /profile/achievements" do
    context "when user is not authenticated" do
      it "redirects to the login page" do
        get achievements_profile_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when user is authenticated" do
      before do
        post login_path, params: { email: user.email, password: user.password }
        create(:user_achievement, user: user, achievement: @achievement1)
      end

      it "returns a successful response" do
        get achievements_profile_path
        expect(response).to be_successful
        expect(response.body).to include("Conquistas")
      end

      it "lists all achievements" do
        get achievements_profile_path
        
        expect(response.body).to include("First Achievement")
        expect(response.body).to include("Second Achievement")
        expect(response.body).to include("Third Achievement")
      end
      
      it "highlights unlocked achievements appropriately" do
        get achievements_profile_path
        
        # unlocked
        expect(response.body).to include("Desbloqueada!")
        
        # locked 
        expect(response.body).to include("Para desbloquear:")
      end
    end
  end
end
