class Achievement < ApplicationRecord
  has_many :user_achievements, dependent: :destroy
  has_many :users, through: :user_achievements

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true

  alias_attribute :title, :name
end
