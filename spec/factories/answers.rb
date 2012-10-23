# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :answer do
    content "MyText"
    question { FactoryGirl.create(:question) }
    response { FactoryGirl.create(:response, :status => 'validating', :survey => FactoryGirl.create(:survey),
                                  :organization_id => 4, :user_id => 2) }

    factory(:answer_with_complete_response) do
      after(:create) do |answer, evaluator|
        answer.response = FactoryGirl.create(:response, :status => 'complete', :survey => FactoryGirl.create(:survey),
                                  :organization_id => 4, :user_id => 2)
        answer.save
      end
    end
  end
end
