require 'rails_helper'

RSpec.describe ItemsHelper, type: :helper do
  describe "#priority_badge" do
    it "returns html with red badge for high priority" do
      item = build(:item, priority: "high")
      expect(helper.priority_badge(item)).to include("🔴 Alta")
      expect(helper.priority_badge(item)).to include("text-red-600")
    end

    it "returns html with yellow badge for medium priority" do
      item = build(:item, priority: "medium")
      expect(helper.priority_badge(item)).to include("🟡 Média")
      expect(helper.priority_badge(item)).to include("text-yellow-600")
    end

    it "returns html with green badge for low priority" do
      item = build(:item, priority: "low")
      expect(helper.priority_badge(item)).to include("🟢 Baixa")
      expect(helper.priority_badge(item)).to include("text-green-600")
    end
  end

  describe "#due_date_class" do
    it "returns red class if overdue" do
      item = build(:item, due_date: 1.day.ago, status: :pending)
      expect(helper.due_date_class(item)).to eq("text-red-500 font-bold")
    end

    it "returns yellow class if due today" do
      item = build(:item, due_date: Date.current, status: :pending)
      expect(helper.due_date_class(item)).to eq("text-yellow-500 font-bold")
    end

    it "returns gray class if due later or no due date" do
      item = build(:item, due_date: 1.day.from_now)
      expect(helper.due_date_class(item)).to eq("text-gray-500")

      item2 = build(:item, due_date: nil)
      expect(helper.due_date_class(item2)).to eq("text-gray-500")
    end
  end
end
