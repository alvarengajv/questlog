require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to have_secure_password }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it 'validates format of email' do
      user = build(:user, email: 'invalid_email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')

      valid_user = build(:user, email: 'valid@example.com')
      valid_user.valid?
      expect(valid_user.errors[:email]).to be_empty
    end

    it { is_expected.to validate_length_of(:password).is_at_least(6) }
  end

  describe 'associations' do
    it { is_expected.to have_one(:gamification_profile).dependent(:destroy) }
    it { is_expected.to have_many(:task_lists).dependent(:destroy) }
    it { is_expected.to have_many(:user_achievements).dependent(:destroy) }
    it { is_expected.to have_many(:achievements).through(:user_achievements) }
  end

  describe 'callbacks' do
    describe 'after_create #create_gamification_profile!' do
      it 'automatically creates a gamification profile for the user' do
        user = build(:user)
        expect { user.save! }.to change(GamificationProfile, :count).by(1)
        expect(user.gamification_profile).to be_present
      end
    end
  end
end
