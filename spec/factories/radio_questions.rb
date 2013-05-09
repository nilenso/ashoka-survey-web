FactoryGirl.define do
  factory :radio_question, :parent => :question, :class => RadioQuestion do
    type 'RadioQuestion'

    trait :with_options do
      after(:create) do |question|
        create_list(:option, 5, :question => question)
      end
    end
  end
end
