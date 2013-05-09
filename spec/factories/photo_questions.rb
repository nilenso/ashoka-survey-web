FactoryGirl.define do
  factory :photo_question, :parent => :question, :class => PhotoQuestion do
    type 'PhotoQuestion'
  end
end
