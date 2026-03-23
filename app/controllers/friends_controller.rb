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
    @accepted_friendship = current_user.friendships.accepted.where(friend: friendship.user).includes(:friend).first

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(friendship),
          turbo_stream.append("accepted_friends", partial: "friends/friend", locals: { friendship: @accepted_friendship })
        ]
      end
      format.html { redirect_to friends_path, notice: "Amizade aceita!" }
    end
  end

  def destroy
    friendship = Friendship.find(params[:id])
    @pending_reject = friendship.status == "pending" && friendship.friend == current_user
    friend = @pending_reject ? friendship.user : friendship.friend

    Friendship.transaction do
      friendship.destroy!
      Friendship.find_by(user: friend, friend: current_user)&.destroy! unless @pending_reject
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(friendship) }
      format.html { redirect_to friends_path, notice: @pending_reject ? "Convite recusado." : "Amizade removida." }
    end
  end
end
