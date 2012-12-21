# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey do
    sequence(:name) { |n| "name_#{n}" }
    expiry_date Date.today + 100.days
    description "MyText"
    finalized :false

    factory :survey_with_questions do
      after(:create) do |survey, evaluator|
        survey.finalize
        FactoryGirl.create_list(:question_with_answers, 5, :survey => survey)
      end
    end
  end
end
