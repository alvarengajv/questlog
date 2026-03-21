require 'rails_helper'

RSpec.describe "Items", type: :request do
  let(:user) { User.create!(email: "test@example.com", password: "password") }
  let(:gamification_profile) { user.gamification_profile } # if it automatically creates one
  let(:task_list) { TaskList.create!(title: "List 1", user: user) }
  let!(:item) { Item.create!(content: "Item 1", task_list: task_list, status: :pending) }

  before do
    post login_path, params: { email: user.email, password: "password" }
  end

  describe "POST /task_lists/:task_list_id/items" do
    let(:valid_attributes) { { content: "New item", priority: "high", due_date: Date.tomorrow, recurrence: "daily" } }

    it "creates a new item and appends via turbo stream" do
      expect {
        post task_list_items_path(task_list), params: { item: valid_attributes }, as: :turbo_stream
      }.to change(Item, :count).by(1)

      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream action=\"append\" target=\"items\"")
      
      new_item = Item.last
      expect(new_item.content).to eq("New item")
      expect(new_item.position).to eq(1)
      # Since Item 1 position was not set in let! it might be nil, so new_item.position could be 1. We just check count.
    end
  end

  describe "PATCH /task_lists/:task_list_id/items/:id" do
    let(:new_attributes) { { content: "Updated content", priority: "low" } }

    it "updates the requested item and replaces via turbo stream" do
      patch task_list_item_path(task_list, item), params: { item: new_attributes }, as: :turbo_stream
      item.reload
      expect(item.content).to eq("Updated content")
      expect(item.priority).to eq("low")

      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream action=\"replace\" target=\"item_#{item.id}\"")
    end
  end

  describe "DELETE /task_lists/:task_list_id/items/:id" do
    it "destroys the requested item and removes via turbo stream" do
      expect {
        delete task_list_item_path(task_list, item), as: :turbo_stream
      }.to change(Item, :count).by(-1)

      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream action=\"remove\" target=\"item_#{item.id}\"")
    end
  end

  describe "PATCH /task_lists/:task_list_id/items/:id/toggle" do
    it "toggles status from pending to completed and calls services" do
      expect(GamificationService).to receive(:item_completed!).with(user, item)
      expect(RecurrenceService).to receive(:process!).with(item)

      patch toggle_task_list_item_path(task_list, item), as: :turbo_stream
      item.reload
      expect(item.status).to eq("completed")

      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream action=\"replace\" target=\"item_#{item.id}\"")
    end

    it "toggles status from completed to pending without calling GamificationService" do
      item.completed!
      
      expect(GamificationService).not_to receive(:item_completed!)
      expect(RecurrenceService).to receive(:process!).with(item)

      patch toggle_task_list_item_path(task_list, item), as: :turbo_stream
      item.reload
      expect(item.status).to eq("pending")
    end
  end

  describe "PATCH /task_lists/:task_list_id/items/:id/sort" do
    let!(:item2) { Item.create!(content: "Item 2", task_list: task_list, position: 2) }
    let!(:item3) { Item.create!(content: "Item 3", task_list: task_list, position: 3) }

    it "updates positions based on the provided array of ids" do
      # Let item be position 1, item2 position 2, item3 position 3
      item.update!(position: 1)

      ordered_ids = [item3.id, item.id, item2.id]

      patch sort_task_list_item_path(task_list, item), params: { item_ids: ordered_ids }

      expect(response).to have_http_status(:ok)
      
      expect(item3.reload.position).to eq(1)
      expect(item.reload.position).to eq(2)
      expect(item2.reload.position).to eq(3)
    end
  end
end
