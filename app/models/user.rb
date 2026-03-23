class User < ApplicationRecord
  has_secure_password

  has_one :gamification_profile, dependent: :destroy
  has_many :task_lists, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  after_create :create_gamification_profile!
end
