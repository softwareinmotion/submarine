FactoryGirl.define do
  factory :issue do
    sequence(:name) {|n| "issue#{n}"}
    sequence(:description) {|n| "desc#{n}"}
    type "Issue"
    association :project
  end
end