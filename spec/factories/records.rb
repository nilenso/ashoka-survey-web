# Read about factories at https://github.com/thoughtbot/factory_girl

include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :record do
    category_id { FactoryGirl.create(:category).id }
    response_id { FactoryGirl.create(:response).id }
  end
end