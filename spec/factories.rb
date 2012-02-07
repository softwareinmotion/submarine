FactoryGirl.define do
  factory :bug do
    sequence(:name) {|n| "bug##{n}"}
    association :project
  end

  factory :task do
    sequence(:name) {|n| "task##{n}"}
    association :project
  end

  factory :user_story do
    sequence(:name) {|n| "user_story#{n}"}
    association :project
  end
  
  factory :issue do
    sequence(:name) {|n| "issue#{n}"}
    type "Task"
    association :project
  end
  
  factory :project do
    sequence(:name) {|n| "Project_#{n}"}
  end
end
