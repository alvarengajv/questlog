class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: 0, accepted: 1 }

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :cannot_friend_self

  scope :accepted, -> { where(status: :accepted) }
  scope :pending_for, ->(user) { where(friend: user, status: :pending) }

  def accept!
    transaction do
      update!(status: :accepted)
      reverse = Friendship.find_or_initialize_by(user: friend, friend: user)
      reverse.status = :accepted
      reverse.save!
    end
  end

  private

  def cannot_friend_self
    errors.add(:friend, "can't be yourself") if user_id == friend_id
  end
end
