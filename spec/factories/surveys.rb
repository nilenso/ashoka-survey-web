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

    factory :survey_with_all do
      ignore do
        options_count 5
      end
      after(:create) do |survey, evaluator|
        FactoryGirl.create_list(:question_with_answers, 5, :survey => survey)
        FactoryGirl.create_list(:category, 5, :survey => survey)
        question = survey.questions.first
        question.type = 'RadioQuestion' if question.type.blank?
        FactoryGirl.create_list(:option, evaluator.options_count, :question => question)
        question.save
        survey.save
        survey.finalize
      end
    end
  end
end
