# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey_question do
    question "MyText"
    survey nil
  end
end
