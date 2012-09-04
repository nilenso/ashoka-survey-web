# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey do
    sequence(:name) { |n| "name_#{n}" }
    expiry_date Date.tomorrow
    description "MyText"

    factory :survey_with_questions do
      after(:create) do |survey, evaluator|
        FactoryGirl.create_list(:question_with_answers, 5, :survey => survey)
      end
    end
  end
end
