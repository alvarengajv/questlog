require "rails_helper"

RSpec.describe "Drag and Drop", type: :system do
  let(:user) { create(:user) }
  let!(:list_a) { create(:task_list, user: user, title: "List A") }
  let!(:list_b) { create(:task_list, user: user, title: "List B") }
  let!(:item) { create(:item, task_list: list_a, content: "Move Me") }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(user)
    visit root_path
  end

  def login_as(user)
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Senha", with: "password123" # FactoryBot default for users
    click_button "Entrar"
    expect(page).to have_content("Quest Board")
  end

  it "moves an item from List A to List B" do
    # Verify initial state
    within "##{dom_id(list_a)}" do
      expect(page).to have_content("Move Me")
    end
    within "##{dom_id(list_b)}" do
      expect(page).not_to have_content("Move Me")
    end

    # Perform drag and drop
    # SortableJS is tricky to test with Capybara's drag_to.
    # We might need to use a JS script to simulate it.
    source = find("##{dom_id(item)}")
    target = find("[data-task-list-id='#{list_b.id}']")

    # Trying JS simulation for SortableJS
    page.execute_script(<<~JS, source, target)
      const source = arguments[0];
      const target = arguments[1];
      const dataTransfer = new DataTransfer();
      
      source.dispatchEvent(new DragEvent('dragstart', { bubbles: true, cancelable: true, dataTransfer }));
      target.dispatchEvent(new DragEvent('drop', { bubbles: true, cancelable: true, dataTransfer }));
      source.dispatchEvent(new DragEvent('dragend', { bubbles: true, cancelable: true, dataTransfer }));
    JS

    # Verify final state in UI
    expect(page).to have_css("##{dom_id(list_b)} ##{dom_id(item)}")
    expect(page).not_to have_css("##{dom_id(list_a)} ##{dom_id(item)}")

    # Verify final state in database
    expect(item.reload.task_list_id).to eq(list_b.id)
  end
end
