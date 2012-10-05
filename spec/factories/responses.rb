# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :response do
    factory :response_with_answers do
      after(:create) do |response, evaluator|
        FactoryGirl.create_list(:answer, 5, :response => response)
      end
    end
  end
end

