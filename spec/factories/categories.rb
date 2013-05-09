FactoryGirl.define do
  factory :category do
    survey
    content "This is a category"
    order_number 0
  end

  factory :multi_record_category, :parent => :category, :class => MultiRecordCategory do
    type 'MultiRecordCategory'
  end
end
