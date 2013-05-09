FactoryGirl.define do
  factory :multi_record_category, :parent => :category, :class => MultiRecordCategory do
    type 'MultiRecordCategory'
  end
end
