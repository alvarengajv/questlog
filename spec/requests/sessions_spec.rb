require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:password) { 'password123' }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  describe "GET /login" do
    it "renders the login form" do
      get login_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Entrar")
      expect(response.body).to include('type="email"')
      expect(response.body).to include('type="password"')
    end
  end

  describe "POST /login" do
    context "with valid credentials" do
      it "sets the session and redirects to root" do
        post login_path, params: { email: user.email, password: password }
        
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(root_path)
        
        follow_redirect!
        expect(response.body).to include("Login realizado com sucesso.")
      end
    end

    context "with invalid credentials" do
      it "re-renders the login form with an error message" do
        post login_path, params: { email: user.email, password: 'wrongpassword' }
        
        expect(session[:user_id]).to be_nil
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Email ou senha inválidos.")
      end
    end
  end

  describe "DELETE /logout" do
    before do
      post login_path, params: { email: user.email, password: password }
    end

    it "clears the session and redirects to /login" do
      expect(session[:user_id]).to eq(user.id)
      
      delete logout_path
      
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_path)
      
      follow_redirect!
      expect(response.body).to include("Você saiu com sucesso.")
    end
  end
end
