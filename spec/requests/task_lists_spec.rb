require 'rails_helper'

RSpec.describe "TaskLists", type: :request do
  let(:password) { 'password123' }
  let(:user) { create(:user, password: password, password_confirmation: password) }
  let(:other_user) { create(:user) }
  let(:task_list) { create(:task_list, user: user) }
  let(:other_task_list) { create(:task_list, user: other_user) }

  before do
    post login_path, params: { email: user.email, password: password }
  end

  describe "GET /task_lists" do
    it "requires authentication" do
      delete logout_path
      get task_lists_path
      expect(response).to redirect_to(login_path)
    end

    it "loads active and archived lists for current user" do
      active_list = create(:task_list, user: user, status: :active, title: "Active List")
      archived_list = create(:task_list, user: user, status: :archived, title: "Archived List")
      other_user_list = create(:task_list, user: other_user, title: "Other User List")

      get task_lists_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(active_list.title)
      expect(response.body).to include(archived_list.title)
      expect(response.body).not_to include(other_user_list.title)
    end

    it "accepts search parameter" do
      matching = create(:task_list, user: user, title: "Learn Ruby")
      non_matching = create(:task_list, user: user, title: "Learn Python")

      get task_lists_path, params: { search: "Ruby" }

      expect(response.body).to include(matching.title)
      expect(response.body).not_to include(non_matching.title)
    end
  end

  describe "GET /task_lists/:id" do
    it "loads pending and completed items" do
      pending_item = create(:item, task_list: task_list, status: :pending, content: "Pending task to do")
      completed_item = create(:item, task_list: task_list, status: :completed, content: "Finished task")

      get task_list_path(task_list)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Pending task to do")
      expect(response.body).to include("Finished task")
    end

    it "returns 404 for another user's list" do
      get task_list_path(other_task_list)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /task_lists" do
    let(:valid_attributes) { { title: "New List", color: "#FFFFFF" } }

    context "with valid parameters" do
      it "creates a new TaskList" do
        expect {
          post task_lists_path, params: { task_list: valid_attributes }
        }.to change(TaskList, :count).by(1)
        expect(TaskList.last.user).to eq(user)
      end

      it "responds with HTML redirect" do
        post task_lists_path, params: { task_list: valid_attributes }
        expect(response).to redirect_to(task_lists_path)
      end

      it "responds with Turbo Stream (prepend)" do
        post task_lists_path, params: { task_list: valid_attributes }, as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include('turbo-stream action="prepend" target="task_lists"')
      end
    end
  end

  describe "PATCH /task_lists/:id" do
    let(:new_attributes) { { title: "Updated Title" } }

    it "updates the requested task_list" do
      patch task_list_path(task_list), params: { task_list: new_attributes }
      task_list.reload
      expect(task_list.title).to eq("Updated Title")
    end
  end

  describe "DELETE /task_lists/:id" do
    it "destroys the requested task_list" do
      task_list # create it
      expect {
        delete task_list_path(task_list)
      }.to change(TaskList, :count).by(-1)
    end
  end

  describe "PATCH /task_lists/:id/archive" do
    it "sets archived true and responds with Turbo Stream remove" do
      patch archive_task_list_path(task_list), as: :turbo_stream
      task_list.reload
      expect(task_list.status).to eq("archived")
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream action=\"remove\" target=\"task_list_#{task_list.id}\"")
    end
  end

  describe "PATCH /task_lists/:id/restore" do
    let(:archived_list) { create(:task_list, user: user, status: :archived) }

    it "sets archived false and responds with Turbo Stream prepend" do
      patch restore_task_list_path(archived_list), as: :turbo_stream
      archived_list.reload
      expect(archived_list.status).to eq("active")
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('turbo-stream action="prepend" target="task_lists"')
    end
  end
end
