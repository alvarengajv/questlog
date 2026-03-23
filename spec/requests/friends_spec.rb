require 'rails_helper'

RSpec.describe "Friends", type: :request do
  let(:password) { 'password123' }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  describe "unauthenticated access" do
    it "redirects GET /friends to login" do
      get friends_path
      expect(response).to redirect_to(login_path)
    end

    it "redirects POST /friends to login" do
      post friends_path, params: { email: "test@example.com" }
      expect(response).to redirect_to(login_path)
    end

    it "redirects PATCH /friends/:id/accept to login" do
      patch accept_friend_path(1)
      expect(response).to redirect_to(login_path)
    end

    it "redirects DELETE /friends/:id to login" do
      delete friend_path(1)
      expect(response).to redirect_to(login_path)
    end
  end

  context "when authenticated" do
    before do
      post login_path, params: { email: user.email, password: password }
    end

    describe "GET /friends" do
      it "returns a successful response" do
        get friends_path
        expect(response).to be_successful
      end

      it "lists accepted friends" do
        friend = create(:user, name: "Amigo Aceito")
        create(:friendship, :accepted, user: user, friend: friend)
        create(:friendship, :accepted, user: friend, friend: user)

        get friends_path
        expect(response.body).to include("Amigo Aceito")
      end

      it "lists pending received invites" do
        sender = create(:user, name: "Remetente")
        create(:friendship, :pending, user: sender, friend: user)

        get friends_path
        expect(response.body).to include("Remetente")
        expect(response.body).to include("Aceitar")
      end

      it "lists pending sent invites" do
        receiver = create(:user, name: "Destinatário")
        create(:friendship, :pending, user: user, friend: receiver)

        get friends_path
        expect(response.body).to include("Destinatário")
        expect(response.body).to include("Pendente")
      end
    end

    describe "POST /friends" do
      it "creates a pending friendship with a valid email" do
        friend = create(:user, email: "friend@example.com")

        expect {
          post friends_path, params: { email: "friend@example.com" }
        }.to change(Friendship, :count).by(1)

        expect(response).to redirect_to(friends_path)
        follow_redirect!
        expect(response.body).to include("Convite enviado com sucesso!")
      end

      it "rejects invitation to self" do
        post friends_path, params: { email: user.email }
        expect(response).to redirect_to(friends_path)
        follow_redirect!
        expect(response.body).to include("Você não pode adicionar a si mesmo")
      end

      it "rejects invitation to non-existent email" do
        post friends_path, params: { email: "nobody@example.com" }
        expect(response).to redirect_to(friends_path)
        follow_redirect!
        expect(response.body).to include("Nenhum usuário encontrado")
      end

      it "rejects duplicate invitation" do
        friend = create(:user)
        create(:friendship, :pending, user: user, friend: friend)

        post friends_path, params: { email: friend.email }
        expect(response).to redirect_to(friends_path)
        follow_redirect!
        expect(response.body).to include("Convite já enviado")
      end
    end

    describe "PATCH /friends/:id/accept" do
      it "accepts a pending friendship and creates bidirectional record" do
        sender = create(:user)
        friendship = create(:friendship, :pending, user: sender, friend: user)

        expect {
          patch accept_friend_path(friendship)
        }.to change(Friendship, :count).by(1)

        friendship.reload
        expect(friendship.status).to eq("accepted")

        reverse = Friendship.find_by(user: user, friend: sender)
        expect(reverse).to be_present
        expect(reverse.status).to eq("accepted")

        expect(response).to redirect_to(friends_path)
      end
    end

    describe "DELETE /friends/:id" do
      it "removes both friendship records" do
        friend = create(:user)
        friendship = create(:friendship, :accepted, user: user, friend: friend)
        create(:friendship, :accepted, user: friend, friend: user)

        expect {
          delete friend_path(friendship)
        }.to change(Friendship, :count).by(-2)

        expect(response).to redirect_to(friends_path)
      end
    end
  end
end
