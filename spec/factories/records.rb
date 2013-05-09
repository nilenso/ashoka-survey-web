FactoryGirl.define do
  factory :record do
    category_id { FactoryGirl.create(:category).id }
    response_id { FactoryGirl.create(:response).id }
  end
end
