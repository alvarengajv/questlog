require 'rails_helper'

RSpec.describe Achievement, type: :model do
  describe 'associations' do
    it { should have_many(:user_achievements).dependent(:destroy) }
    it { should have_many(:users).through(:user_achievements) }
  end

  describe 'validations' do
    subject { build(:achievement) }
    
    it { should validate_presence_of(:key) }
    it { should validate_uniqueness_of(:key) }
    it { should validate_presence_of(:name) }
  end

  describe 'aliases' do
    it 'aliases name to title' do
      achievement = build(:achievement, name: 'First Blood')
      expect(achievement.title).to eq('First Blood')
      
      achievement.title = 'New Title'
      expect(achievement.name).to eq('New Title')
    end
  end
end
