FactoryGirl.define do
  factory :single_line_question, :parent => :question, :class => SingleLineQuestion do
    type 'SingleLineQuestion'
  end
end
