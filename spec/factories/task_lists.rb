FactoryBot.define do
  factory :task_list do
    user
    title { "MyString" }

    trait :archived do
      status { :archived }
    end
  end
end
