FactoryGirl.define do
  factory :rating_question, :parent => :question, :class => RatingQuestion do
    type 'RatingQuestion'
  end
end
