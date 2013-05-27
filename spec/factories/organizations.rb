FactoryGirl.define do
  factory :organization do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "name_#{n}" }

    initialize_with { new(id, name) }
  end
end
