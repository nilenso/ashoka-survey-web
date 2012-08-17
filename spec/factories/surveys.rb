# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey do
    sequence(:name) { |n| "name_#{n}" }
    expiry_date "2012-08-16"
    description "MyText"
    questions { FactoryGirl.create(:question) }
  end
end
