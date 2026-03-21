FactoryBot.define do
  factory :item do
    task_list
    content { "MyString" }
    priority { 1 }
    recurrence { 1 }
  end
end
