# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do
    content "This is a category"
    order_number 0
  end
end
