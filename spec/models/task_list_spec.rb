require 'rails_helper'

RSpec.describe TaskList, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:items).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(100) }

    it 'allows valid hex colors' do
      list = build(:task_list, color: '#FF0000')
      expect(list).to be_valid
    end

    it 'rejects invalid hex colors' do
      list = build(:task_list, color: 'FF0000')
      expect(list).not_to be_valid
      list.color = '#GG0000'
      expect(list).not_to be_valid
    end

    it 'allows blank colors' do
      list = build(:task_list, color: nil)
      expect(list).to be_valid
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(active: 0, archived: 1) }
  end

  describe 'scopes' do
    describe '.search' do
      let!(:user) { create(:user) }
      let!(:task_list1) { create(:task_list, title: 'Learn Ruby', user: user) }
      let!(:task_list2) { create(:task_list, title: 'Learn Rails', user: user) }
      let!(:task_list3) { create(:task_list, title: 'Master React', user: user) }

      it 'returns task lists matching the query' do
        expect(TaskList.search('Learn')).to match_array([task_list1, task_list2])
        expect(TaskList.search('react')).to match_array([task_list3])
        expect(TaskList.search('ruby')).to match_array([task_list1])
      end
    end
  end

  describe '#progress_percentage' do
    let(:user) { create(:user) }
    let(:task_list) { create(:task_list, user: user) }

    context 'when there are no items' do
      it 'returns 0' do
        expect(task_list.progress_percentage).to eq(0)
      end
    end

    context 'when there are items' do
      it 'calculates the correct percentage' do
        create(:item, task_list: task_list, status: :completed)
        create(:item, task_list: task_list, status: :completed)
        create(:item, task_list: task_list, status: :pending)
        create(:item, task_list: task_list, status: :pending)

        expect(task_list.progress_percentage).to eq(50)

        task_list.items.last.update(status: :completed)
        expect(task_list.progress_percentage).to eq(75)
      end
    end
  end

  describe '#complete?' do
    let(:user) { create(:user) }
    let(:task_list) { create(:task_list, user: user) }

    context 'when there are no items' do
      it 'returns false' do
        expect(task_list.complete?).to be false
      end
    end

    context 'when there are items' do
      it 'returns true if all items are completed' do
        create(:item, task_list: task_list, status: :completed)
        create(:item, task_list: task_list, status: :completed)
        expect(task_list.complete?).to be true
      end

      it 'returns false if any item is pending' do
        create(:item, task_list: task_list, status: :completed)
        create(:item, task_list: task_list, status: :pending)
        expect(task_list.complete?).to be false
      end
    end
  end
end
