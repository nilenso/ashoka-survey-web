FactoryGirl.define do
  factory :drop_down_question, :parent => :question, :class => DropDownQuestion do
    type 'DropDownQuestion'
  end
end
