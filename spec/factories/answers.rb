# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :answer do
    content "MyText"
    question { FactoryGirl.create(:question) }
    response { FactoryGirl.create(:response, :complete => true, :survey => FactoryGirl.create(:survey),
    								:organization_id => 4, :user_id => 2) }
  end
end
