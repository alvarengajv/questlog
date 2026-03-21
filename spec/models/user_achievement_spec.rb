require 'rails_helper'

RSpec.describe UserAchievement, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:achievement) }
  end

  describe 'validations' do
    subject { create(:user_achievement) }
    
    it { should validate_uniqueness_of(:user_id).scoped_to(:achievement_id) }
  end
end
