# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :response do
    survey { FactoryGirl.create :survey }
    before(:create) do |response|
      response.organization_id = 1 if response.organization_id.blank?
      response.user_id = 1 if response.user_id.blank?
      response.save
    end    
    factory :response_with_answers do
      after(:create) do |response, evaluator|
        FactoryGirl.create_list(:answer, 5, :response => response)
      end
    end
  end
end

