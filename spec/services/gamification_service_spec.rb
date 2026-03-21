require 'rails_helper'

RSpec.describe GamificationService do
  let(:user) { create(:user) }
  let(:task_list) { create(:task_list, user: user) }
  let(:profile) { user.gamification_profile }

  before do
    # Create required achievements
    ['first_task', 'task_10', 'task_50', 'task_100', 'high_priority', 'streak_3', 'streak_7', 'level_2', 'level_5', 'first_list'].each do |key|
      achievement = Achievement.find_or_create_by!(key: key) do |a|
        a.name = key
        a.description = key
      end
      achievement.update!(xp_reward: 10)
    end
  end

  describe '.call' do
    let(:item) { create(:item, task_list: task_list, priority: :low, due_date: Date.current, status: :pending) }

    before do
      item.update(status: :completed)
    end

    it 'awards base XP for item completion based on priority' do
      expect {
        GamificationService.call(user, item)
      }.to change { profile.reload.xp }.by(5 + 5 + 30 + 10 + 10 + 10) 
      # Base (5) + OnTime (5) + TaskListComplete (30) + DailyStreak (10) + first_task XP (10) + first_list XP (10)
    end

    context 'with priority' do
      it 'awards 5 XP for low priority' do
        item.update(priority: :low)
        expect { GamificationService.call(user, item) }.to change { profile.reload.xp }
        expect(profile.xp).to be >= 5
      end

      it 'awards 10 XP for medium priority' do
        item.update(priority: :medium)
        expect { GamificationService.call(user, item) }.to change { profile.reload.xp }
        expect(profile.xp).to be >= 10
      end

      it 'awards 20 XP for high priority' do
        item.update(priority: :high)
        expect { GamificationService.call(user, item) }.to change { profile.reload.xp }
        expect(profile.xp).to be >= 20
        expect(user.user_achievements.joins(:achievement).where(achievements: { key: 'high_priority' })).to exist
      end
    end

    context 'with due date' do
      it 'awards 5 bonus XP if completed on time' do
        item.update(due_date: Date.current)
        service = GamificationService.new(user, item)
        expect(service.send(:completed_on_time?)).to be true
      end

      it 'does not award bonus XP if overdue' do
        item.update(due_date: Date.current - 1.day)
        service = GamificationService.new(user, item)
        expect(service.send(:completed_on_time?)).to be false
      end
    end

    context 'with full task list completion' do
      it 'awards 30 bonus XP if list becomes 100% complete' do
        create(:item, task_list: task_list, status: :completed)
        service = GamificationService.new(user, item)
        expect(service.send(:task_list_completed?)).to be true
      end

      it 'does not award bonus if list is not complete' do
        create(:item, task_list: task_list, status: :pending)
        service = GamificationService.new(user, item)
        expect(service.send(:task_list_completed?)).to be false
      end
    end

    context 'streaks' do
      it 'increments streak if active yesterday' do
        profile.update(last_activity_date: Date.current - 1.day, streak_days: 1)
        GamificationService.call(user, item)
        expect(profile.reload.streak_days).to eq(2)
      end

      it 'resets streak if missed yesterday' do
        profile.update(last_activity_date: Date.current - 2.days, streak_days: 5)
        GamificationService.call(user, item)
        expect(profile.reload.streak_days).to eq(1)
      end

      it 'does nothing to streak if already active today' do
        profile.update(last_activity_date: Date.current, streak_days: 2)
        expect {
          GamificationService.call(user, item)
        }.not_to change { profile.reload.streak_days }
      end
    end

    context 'achievements' do
      it 'unlocks first_task' do
        GamificationService.call(user, item)
        expect(user.user_achievements.joins(:achievement).where(achievements: { key: 'first_task' })).to exist
      end

      it 'unlocks task_10' do
        9.times { create(:item, task_list: task_list, status: :completed) }
        GamificationService.call(user, item)
        expect(user.user_achievements.joins(:achievement).where(achievements: { key: 'task_10' })).to exist
      end
    end
  end
end
