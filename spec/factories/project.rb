FactoryGirl.define do
  factory :project do
    sequence(:name) {|n| "Projekt#{n}"}
  end
end