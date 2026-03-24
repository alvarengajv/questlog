require 'rails_helper'

RSpec.describe AttributeService do
  let(:user) { create(:user) }

  describe '.scores_for' do
    context 'with multiple lists and mixed priorities' do
      it 'returns correct scores per list' do
        list_a = create(:task_list, user: user, title: "Força")
        list_b = create(:task_list, user: user, title: "Inteligência")

        create(:item, :completed, task_list: list_a, priority: :high)   # 20
        create(:item, :completed, task_list: list_a, priority: :low)    # 5
        create(:item, :completed, task_list: list_b, priority: :medium) # 10

        scores = described_class.scores_for(user)

        expect(scores["Força"]).to eq(25)
        expect(scores["Inteligência"]).to eq(10)
      end
    end

    context 'with an empty list (no items)' do
      it 'returns 0 for the list' do
        create(:task_list, user: user, title: "Vazia")

        scores = described_class.scores_for(user)

        expect(scores["Vazia"]).to eq(0)
      end
    end

    context 'with all items pending' do
      it 'returns 0 for the list' do
        list = create(:task_list, user: user, title: "Pendentes")
        create(:item, task_list: list, priority: :high, status: :pending)
        create(:item, task_list: list, priority: :medium, status: :pending)

        scores = described_class.scores_for(user)

        expect(scores["Pendentes"]).to eq(0)
      end
    end

    context 'with mixed priorities in completed items' do
      it 'sums xp_value correctly (low=5, medium=10, high=20)' do
        list = create(:task_list, user: user, title: "Mista")
        create(:item, :completed, task_list: list, priority: :low)    # 5
        create(:item, :completed, task_list: list, priority: :medium) # 10
        create(:item, :completed, task_list: list, priority: :high)   # 20

        scores = described_class.scores_for(user)

        expect(scores["Mista"]).to eq(35)
      end
    end

    context 'with archived lists' do
      it 'excludes archived lists from results' do
        create(:task_list, user: user, title: "Ativa")
        create(:task_list, :archived, user: user, title: "Arquivada")

        scores = described_class.scores_for(user)

        expect(scores).to have_key("Ativa")
        expect(scores).not_to have_key("Arquivada")
      end
    end
  end

  describe '.normalize' do
    context 'with varied values' do
      it 'normalizes to 0-100 scale with max as 100' do
        scores = { "A" => 100, "B" => 50, "C" => 25 }

        result = described_class.normalize(scores)

        expect(result["A"]).to eq(100)
        expect(result["B"]).to eq(50)
        expect(result["C"]).to eq(25)
      end
    end

    context 'with non-round proportions' do
      it 'rounds proportional values' do
        scores = { "A" => 30, "B" => 20, "C" => 10 }

        result = described_class.normalize(scores)

        expect(result["A"]).to eq(100)
        expect(result["B"]).to eq(67)
        expect(result["C"]).to eq(33)
      end
    end

    context 'with all zeros' do
      it 'returns all zeros' do
        scores = { "A" => 0, "B" => 0, "C" => 0 }

        result = described_class.normalize(scores)

        expect(result.values).to all(eq(0))
      end
    end

    context 'with a single value' do
      it 'normalizes the single value to 100' do
        scores = { "A" => 42 }

        result = described_class.normalize(scores)

        expect(result["A"]).to eq(100)
      end
    end

    context 'with a single zero value' do
      it 'returns 0' do
        scores = { "A" => 0 }

        result = described_class.normalize(scores)

        expect(result["A"]).to eq(0)
      end
    end

    context 'with empty hash' do
      it 'returns empty hash' do
        expect(described_class.normalize({})).to eq({})
      end
    end
  end
end
