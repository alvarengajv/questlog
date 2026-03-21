class TaskList < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy

  enum :status, { active: 0, archived: 1 }

  validates :title, presence: true, length: { maximum: 100 }
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/i }, allow_blank: true

  scope :search, ->(query) { where("title ILIKE ?", "%#{query}%") }

  def progress_percentage
    return 0 if items.empty?

    completed_count = items.completed.count
    (completed_count.to_f / items.count * 100).to_i
  end

  def complete?
    items.any? && items.all?(&:completed?)
  end
end
