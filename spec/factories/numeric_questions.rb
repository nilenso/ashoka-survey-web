FactoryGirl.define do
  factory :numeric_question, :parent => :question, :class => NumericQuestion do
    type 'NumericQuestion'
  end
end
