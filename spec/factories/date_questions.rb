FactoryGirl.define do
  factory :date_question, :parent => :question, :class => DateQuestion do
    type 'DateQuestion'
  end
end
