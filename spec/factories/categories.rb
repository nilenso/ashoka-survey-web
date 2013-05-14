FactoryGirl.define do
  factory :category do
    survey
    content "This is a category"
    order_number 0

    trait :finalized do
      finalized true
    end

    factory :multi_record_category, :parent => :category, :class => MultiRecordCategory do
      type 'MultiRecordCategory'
    end
  end
end
