FactoryBot.define do
  factory :item do
    task_list
    content { "MyString" }
    priority { :low }
    recurrence { :none_recurrence }

    trait :completed do
      status { :completed }
    end

    trait :high_priority do
      priority { :high }
    end

    trait :overdue do
      due_date { 3.days.ago.to_date }
      status { :pending }
    end

    trait :daily do
      recurrence { :daily }
    end

    trait :weekly do
      recurrence { :weekly }
    end
  end
end
