FactoryGirl.define do
  factory :organization do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "name_#{n}" }
    logos :thumb_url => "http://example.com/logo.png"

    initialize_with { new(id, :name => name, :logo_url => logos[:thumb_url]) }
  end
end
