FactoryBot.define do
  factory :item do
    task_list { nil }
    content { "MyString" }
    priority { 1 }
    recurrence { 1 }
  end
end
