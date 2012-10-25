# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :choice do
    option { FactoryGirl.create :option }
    answer nil
  end
end
