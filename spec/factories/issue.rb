FactoryGirl.define do
  factory :issue do
    sequence(:name) {|n| "issue#{n}"}
    sequence(:description) {|n| "desc#{n}"}
    type "Issue"
    association :project
  end
  
  factory :bug do
    sequence(:name) {|n| "bug##{n}"}
    sequence(:description) {|n| "desc#{n}"}
    association :project
  end

  factory :task do
    sequence(:name) {|n| "task##{n}"}
    sequence(:description) {|n| "desc#{n}"}
    association :project
  end

  factory :user_story do
    sequence(:name) {|n| "user_story#{n}"}
    sequence(:description) {|n| "desc#{n}"}
    association :project
  end 
end
