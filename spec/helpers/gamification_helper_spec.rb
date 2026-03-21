require 'rails_helper'

RSpec.describe GamificationHelper, type: :helper do
  describe "#xp_percentage" do
    it "returns the xp_progress_percentage from profile" do
      profile = build(:gamification_profile, level: 1, xp: 50)
      expect(helper.xp_percentage(profile)).to eq(50)
    end
  end

  describe "#level_title" do
    it "returns correct title for level 1" do
      expect(helper.level_title(1)).to eq("Novato")
    end

    it "returns correct title for level 4" do
      expect(helper.level_title(4)).to eq("Aventureiro")
    end

    it "returns correct title for level 10" do
      expect(helper.level_title(10)).to eq("Lenda Viva")
    end
  end

  describe "#streak_display" do
    it "returns string with fire emoji and days" do
      profile = build(:gamification_profile, streak_days: 5)
      expect(helper.streak_display(profile)).to eq("🔥 5 dias")
    end
  end
end
