require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "enums" do
    it { should define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2) }
    it { should define_enum_for(:recurrence).with_values(none_recurrence: 0, daily: 1, weekly: 2, monthly: 3) }
    
    it "has default priority low" do
      expect(Item.new.priority).to eq("low")
    end

    it "has default recurrence none_recurrence" do
      expect(Item.new.recurrence).to eq("none_recurrence")
    end
  end

  describe "scopes" do
    let(:user) { User.create!(email: "test@example.com", password: "password") }
    let(:task_list) { TaskList.create!(title: "List 1", user: user) }
    let!(:item_completed) { Item.create!(content: "I1", task_list: task_list, status: :completed, priority: :high) }
    let!(:item_pending) { Item.create!(content: "I2", task_list: task_list, status: :pending, priority: :low) }
    let!(:item_medium) { Item.create!(content: "I3", task_list: task_list, status: :pending, priority: :medium) }

    it ".completed returns completed items" do
      expect(Item.completed).to include(item_completed)
      expect(Item.completed).not_to include(item_pending)
    end

    it ".pending returns pending items" do
      expect(Item.pending).to include(item_pending)
      expect(Item.pending).not_to include(item_completed)
    end

    it ".by_priority orders by priority desc" do
      expect(Item.by_priority.pluck(:id)).to eq([item_completed.id, item_medium.id, item_pending.id])
    end
  end

  describe "domain methods" do
    let(:item) { Item.new(content: "Test task") }

    describe "#overdue?" do
      it "returns true if due_date is in the past and pending" do
        item.due_date = 1.day.ago.to_date
        item.status = :pending
        expect(item.overdue?).to be true
      end

      it "returns false if due_date is in the past but completed" do
        item.due_date = 1.day.ago.to_date
        item.status = :completed
        expect(item.overdue?).to be false
      end

      it "returns false if due_date is in the future" do
        item.due_date = 1.day.from_now.to_date
        item.status = :pending
        expect(item.overdue?).to be false
      end

      it "returns false if no due_date" do
        expect(item.overdue?).to be false
      end
    end

    describe "#due_today?" do
      it "returns true if due_date is today" do
        item.due_date = Date.current
        expect(item.due_today?).to be true
      end

      it "returns false if due_date is not today" do
        item.due_date = 1.day.from_now.to_date
        expect(item.due_today?).to be false
      end

      it "returns false if no due_date" do
        expect(item.due_today?).to be false
      end
    end

    describe "#recurring?" do
      it "returns false if recurrence is none_recurrence" do
        item.recurrence = :none_recurrence
        expect(item.recurring?).to be false
      end

      it "returns true if recurrence is daily" do
        item.recurrence = :daily
        expect(item.recurring?).to be true
      end
    end

    describe "#xp_value" do
      it "returns 5 for low priority" do
        item.priority = :low
        expect(item.xp_value).to eq(5)
      end

      it "returns 10 for medium priority" do
        item.priority = :medium
        expect(item.xp_value).to eq(10)
      end

      it "returns 20 for high priority" do
        item.priority = :high
        expect(item.xp_value).to eq(20)
      end
    end
  end
end
