FactoryGirl.define do
  factory :user do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "name_#{n}" }
    sequence(:email) { |n| "foo_#{n}@example.com" }
    role "cso_admin"
    initialize_with { new(id, name, role, email) }
  end
end
