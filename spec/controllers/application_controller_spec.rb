require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # anonymous controller to test the methods
  controller do
    before_action :require_authentication, only: [:protected_action]

    def index
      render plain: "Public"
    end

    def protected_action
      render plain: "Protected"
    end
  end

  let(:user) { create(:user) }

  describe '#current_user' do
    it 'returns the user when session[:user_id] is present' do
      session[:user_id] = user.id
      expect(controller.current_user).to eq(user)
    end

    it 'returns nil when session[:user_id] is absent' do
      expect(controller.current_user).to be_nil
    end

    it 'returns nil when session[:user_id] is invalid' do
      session[:user_id] = -1
      expect(controller.current_user).to be_nil
    end
  end

  describe '#logged_in?' do
    it 'returns true when current_user is present' do
      session[:user_id] = user.id
      expect(controller.logged_in?).to be true
    end

    it 'returns false when current_user is absent' do
      expect(controller.logged_in?).to be false
    end
  end

  describe '#require_authentication' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'allows the request to proceed' do
        routes.draw { get "protected_action" => "anonymous#protected_action" }
        get :protected_action
        expect(response.body).to eq("Protected")
      end
    end

    context 'when user is not logged in' do
      it 'redirects to the login path' do
        routes.draw { get "protected_action" => "anonymous#protected_action" }
        get :protected_action
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Você precisa fazer login para acessar esta página.")
      end
    end
  end
end
