require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:password) { 'password123' }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:profile) { user.gamification_profile }

  before do
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
        post login_path, params: { email: user.email, password: password }

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

        expect(response.body).to include("Novato") # title for level 2
        expect(response.body).to include("150")    # XP
      end

      it "displays recent achievements" do
        get profile_path

        expect(response.body).to include("First Achievement")
        expect(response.body).to include("Second Achievement")
        expect(response.body).not_to include("Third Achievement")
      end

      it "loads attribute scores from active task lists" do
        list = create(:task_list, user: user, title: "Força")
        create(:item, :completed, :high_priority, task_list: list) # 20 XP
        create(:task_list, :archived, user: user, title: "Arquivada")

        scores = { "Força" => 20 }
        normalized = { "Força" => 100 }
        allow(AttributeService).to receive(:scores_for).with(user).and_return(scores)
        allow(AttributeService).to receive(:normalize).with(scores).and_return(normalized)

        get profile_path

        expect(response).to be_successful
        expect(AttributeService).to have_received(:scores_for).with(user)
        expect(AttributeService).to have_received(:normalize).with(scores)
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
        post login_path, params: { email: user.email, password: password }
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

      it "distinguishes unlocked from locked achievements" do
        get achievements_profile_path

        # unlocked achievement shows unlock date
        expect(response.body).to include("Desbloqueada em")

        # page shows unlocked count
        expect(response.body).to include("1/3 desbloqueadas")
      end
    end
  end
end
