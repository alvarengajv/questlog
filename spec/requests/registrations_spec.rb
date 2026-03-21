require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /signup" do
    it "renders the signup form" do
      get signup_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Cadastro")
    end
  end

  describe "POST /signup" do
    context "with valid parameters" do
      let(:valid_params) do
        { user: { email: "test@example.com", password: "password", password_confirmation: "password" } }
      end

      it "creates a new User" do
        expect {
          post signup_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "creates a GamificationProfile for the user" do
        expect {
          post signup_path, params: valid_params
        }.to change(GamificationProfile, :count).by(1)
      end

      it "logs the user in" do
        post signup_path, params: valid_params
        expect(session[:user_id]).to eq(User.last.id)
      end

      it "redirects to the root path" do
        post signup_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { user: { email: "invalid", password: "123", password_confirmation: "321" } }
      end

      it "does not create a new User" do
        expect {
          post signup_path, params: invalid_params
        }.to change(User, :count).by(0)
      end

      it "does not log in the user" do
        post signup_path, params: invalid_params
        expect(session[:user_id]).to be_nil
      end

      it "re-renders the new template with unprocessable_entity status" do
        post signup_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Cadastro")
      end
    end
  end
end
