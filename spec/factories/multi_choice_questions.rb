FactoryGirl.define do
  factory :multi_choice_question, :parent => :question, :class => MultiChoiceQuestion do
    type 'MultiChoiceQuestion'
  end
end
