require 'rails_helper'

RSpec.describe ItemsHelper, type: :helper do
  describe "#priority_badge" do
    it "returns html with red badge for high priority" do
      item = build(:item, priority: "high")
      expect(helper.priority_badge(item)).to include("🔴 Alta")
      expect(helper.priority_badge(item)).to include("badge-high")
    end

    it "returns html with yellow badge for medium priority" do
      item = build(:item, priority: "medium")
      expect(helper.priority_badge(item)).to include("🟡 Média")
      expect(helper.priority_badge(item)).to include("badge-medium")
    end

    it "returns html with green badge for low priority" do
      item = build(:item, priority: "low")
      expect(helper.priority_badge(item)).to include("🟢 Baixa")
      expect(helper.priority_badge(item)).to include("badge-low")
    end
  end

  describe "#recurrence_badge" do
    it "returns nil for non-recurring items" do
      item = build(:item, recurrence: "none_recurrence")
      expect(helper.recurrence_badge(item)).to be_nil
    end

    it "returns badge for daily recurrence" do
      item = build(:item, recurrence: "daily")
      expect(helper.recurrence_badge(item)).to include("🔁 Diária")
      expect(helper.recurrence_badge(item)).to include("badge-recurrence")
    end

    it "returns badge for weekly recurrence" do
      item = build(:item, recurrence: "weekly")
      expect(helper.recurrence_badge(item)).to include("🔁 Semanal")
    end

    it "returns badge for monthly recurrence" do
      item = build(:item, recurrence: "monthly")
      expect(helper.recurrence_badge(item)).to include("🔁 Mensal")
    end
  end

  describe "#due_date_class" do
    it "returns critical-hit class if overdue" do
      item = build(:item, due_date: 1.day.ago, status: :pending)
      expect(helper.due_date_class(item)).to eq("text-[var(--color-critical-hit)] font-semibold")
    end

    it "returns xp-amber class if due today" do
      item = build(:item, due_date: Date.current, status: :pending)
      expect(helper.due_date_class(item)).to eq("text-[var(--color-xp-amber)] font-semibold")
    end

    it "returns quest-gold-dim class if due later or no due date" do
      item = build(:item, due_date: 1.day.from_now)
      expect(helper.due_date_class(item)).to eq("text-[var(--color-quest-gold-dim)]")

      item2 = build(:item, due_date: nil)
      expect(helper.due_date_class(item2)).to eq("text-[var(--color-quest-gold-dim)]")
    end
  end
end
