class FriendsController < ApplicationController
  before_action :require_authentication

  def index
    @accepted_friends = current_user.friendships.accepted.includes(:friend)
    @pending_received = Friendship.pending_for(current_user).includes(:user)
    @pending_sent = current_user.friendships.where(status: :pending).includes(:friend)
  end

  def create
    friend = User.find_by(email: params[:email])

    if friend.nil?
      redirect_to friends_path, alert: "Nenhum usuário encontrado com esse email."
      return
    end

    if friend == current_user
      redirect_to friends_path, alert: "Você não pode adicionar a si mesmo."
      return
    end

    existing = Friendship.find_by(user: current_user, friend: friend)
    if existing
      redirect_to friends_path, alert: "Convite já enviado ou amizade já existe."
      return
    end

    friendship = current_user.friendships.build(friend: friend, status: :pending)

    if friendship.save
      redirect_to friends_path, notice: "Convite enviado com sucesso!"
    else
      redirect_to friends_path, alert: friendship.errors.full_messages.to_sentence
    end
  end

  def accept
    friendship = Friendship.pending_for(current_user).find(params[:id])
    friendship.accept!
    redirect_to friends_path, notice: "Amizade aceita!"
  end

  def destroy
    friendship = current_user.friendships.find(params[:id])
    friend = friendship.friend

    Friendship.transaction do
      friendship.destroy!
      Friendship.find_by(user: friend, friend: current_user)&.destroy!
    end

    redirect_to friends_path, notice: "Amizade removida."
  end
end
