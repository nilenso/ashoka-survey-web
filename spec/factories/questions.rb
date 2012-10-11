# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    content "MyText"
    survey_id { FactoryGirl.create(:survey).id }
    sequence(:order_number, 1000)

    factory :question_with_answers do
      after(:create) do |question, evaluator|
        FactoryGirl.create_list(:answer, 5, :question => question)
      end
    end

    factory :question_with_options do
      after(:create) do |question, evaluator|
        question.type = 'RadioQuestion'
        FactoryGirl.create_list(:option, 5, :question => question)
        question.save
      end
    end
  end
end
