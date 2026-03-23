class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: 0, accepted: 1 }

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :cannot_friend_self

  private

  def cannot_friend_self
    errors.add(:friend, "can't be yourself") if user_id == friend_id
  end
end
