# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey do
    sequence(:name) { |n| "name_#{n}" }
    expiry_date Date.today + 100.days
    description "MyText"
    finalized :false

    trait :finalized do
      finalized true
    end

    trait :archived do
      finalized
      archived true
    end

    trait :public do
      public true
    end

    trait :marked_for_deletion do
      marked_for_deletion true
    end

    factory :survey_with_questions do
      after(:create) do |survey, evaluator|
        FactoryGirl.create_list(:question_with_answers, 5, :survey => survey)
        survey.finalize
      end
    end

    factory :survey_with_categories do
      after(:create) do |survey, evaluator|
        FactoryGirl.create_list(:category, 5, :survey => survey)
        survey.finalize
      end
    end
  end
end
