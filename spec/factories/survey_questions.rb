# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey_question do
    question "This is a question."
    survey nil
  end
end
