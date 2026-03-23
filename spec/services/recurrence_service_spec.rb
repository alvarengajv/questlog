require 'rails_helper'

RSpec.describe RecurrenceService do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:task_list) { create(:task_list, user: user) }

  describe '.call' do
    context 'when item is not recurring (none)' do
      let(:item) { create(:item, task_list: task_list, recurrence: :none_recurrence, status: :completed) }

      it 'returns nil and does not create a new item' do
        item # force creation before count check
        expect { RecurrenceService.call(item) }.not_to change(Item, :count)
        expect(RecurrenceService.call(item)).to be_nil
      end
    end

    context 'when item is not completed' do
      let(:item) { create(:item, task_list: task_list, recurrence: :daily, due_date: Date.current, status: :pending) }

      it 'returns nil and does not create a new item' do
        item # force creation before count check
        expect { RecurrenceService.call(item) }.not_to change(Item, :count)
        expect(RecurrenceService.call(item)).to be_nil
      end
    end

    context 'when item is daily' do
      let(:item) { create(:item, task_list: task_list, content: "Daily task", priority: :high, recurrence: :daily, due_date: Date.new(2026, 3, 23), status: :completed) }

      it 'creates a new item with due_date + 1.day' do
        new_item = RecurrenceService.call(item)

        expect(new_item).to be_persisted
        expect(new_item.due_date).to eq(Date.new(2026, 3, 24))
      end
    end

    context 'when item is weekly' do
      let(:item) { create(:item, task_list: task_list, content: "Weekly task", priority: :medium, recurrence: :weekly, due_date: Date.new(2026, 3, 23), status: :completed) }

      it 'creates a new item with due_date + 1.week' do
        new_item = RecurrenceService.call(item)

        expect(new_item).to be_persisted
        expect(new_item.due_date).to eq(Date.new(2026, 3, 30))
      end
    end

    context 'when item is monthly' do
      let(:item) { create(:item, task_list: task_list, content: "Monthly task", priority: :low, recurrence: :monthly, due_date: Date.new(2026, 3, 23), status: :completed) }

      it 'creates a new item with due_date + 1.month' do
        new_item = RecurrenceService.call(item)

        expect(new_item).to be_persisted
        expect(new_item.due_date).to eq(Date.new(2026, 4, 23))
      end
    end

    context 'when item has no due_date' do
      let(:item) { create(:item, task_list: task_list, content: "No date task", priority: :low, recurrence: :daily, due_date: nil, status: :completed) }

      it 'uses Date.current as base' do
        travel_to Date.new(2026, 3, 23) do
          new_item = RecurrenceService.call(item)

          expect(new_item).to be_persisted
          expect(new_item.due_date).to eq(Date.new(2026, 3, 24))
        end
      end
    end

    context 'new item inherits attributes' do
      let(:item) { create(:item, task_list: task_list, content: "Recurring task", priority: :high, recurrence: :weekly, due_date: Date.new(2026, 3, 23), status: :completed) }

      it 'inherits content, priority, recurrence, and task_list' do
        new_item = RecurrenceService.call(item)

        expect(new_item.content).to eq("Recurring task")
        expect(new_item.priority).to eq("high")
        expect(new_item.recurrence).to eq("weekly")
        expect(new_item.task_list).to eq(task_list)
        expect(new_item.status).to eq("pending")
      end
    end
  end
end
