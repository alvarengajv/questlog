require 'rails_helper'

RSpec.describe GamificationProfile, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:level) }
    it { should validate_numericality_of(:level).is_greater_than_or_equal_to(1) }
    it { should validate_presence_of(:xp) }
    it { should validate_numericality_of(:xp).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:streak_days) }
    it { should validate_numericality_of(:streak_days).is_greater_than_or_equal_to(0) }
  end

  describe 'constants' do
    it 'has 5 levels with minimum XP' do
      expect(GamificationProfile::LEVELS.keys.size).to eq(5)
      expect(GamificationProfile::LEVELS[1]).to eq(0)
      expect(GamificationProfile::LEVELS[2]).to eq(100)
      expect(GamificationProfile::LEVELS[3]).to eq(300)
      expect(GamificationProfile::LEVELS[4]).to eq(600)
      expect(GamificationProfile::LEVELS[5]).to eq(1000)
    end
  end

  describe '#recalculate_level!' do
    let(:user) { create(:user) }
    let(:profile) { user.gamification_profile }

    before do
      profile.update!(xp: 0, level: 1)
    end

    it 'stays at level 1 with 0 XP' do
      profile.recalculate_level!
      expect(profile.level).to eq(1)
    end

    it 'updates to level 2 with 150 XP' do
      profile.update(xp: 150)
      profile.recalculate_level!
      expect(profile.level).to eq(2)
    end

    it 'updates to level 3 with 300 XP' do
      profile.update(xp: 300)
      profile.recalculate_level!
      expect(profile.level).to eq(3)
    end

    it 'updates to level 5 with 1500 XP' do
      profile.update(xp: 1500)
      profile.recalculate_level!
      expect(profile.level).to eq(5)
    end
  end

  describe '#xp_progress_percentage' do
    it 'returns 0-100 percentage based on current level progress' do
      profile = build(:gamification_profile, level: 1, xp: 50)
      # Level 1 to 2 requires 100 xp
      expect(profile.xp_progress_percentage).to eq(50)
      
      profile.xp = 0
      expect(profile.xp_progress_percentage).to eq(0)

      profile.xp = 99
      expect(profile.xp_progress_percentage).to eq(99)

      profile2 = build(:gamification_profile, level: 2, xp: 200)
      # Level 2 to 3 requires 200 xp (300 - 100), has 100/200 = 50%
      expect(profile2.xp_progress_percentage).to eq(50)

      profile_max = build(:gamification_profile, level: 5, xp: 1200)
      expect(profile_max.xp_progress_percentage).to eq(100)
    end
  end
end
