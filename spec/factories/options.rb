# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :option do
    sequence(:content) { |n| "This is option number #{n}" }
    question_id { FactoryGirl.create(:question).id }
  end
end
