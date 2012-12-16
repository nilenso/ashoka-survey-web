# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :participating_organization do
    survey { FactoryGirl.create :survey, :finalized => true }
    organization_id 1
  end
end
