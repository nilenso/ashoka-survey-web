FactoryGirl.define do
  factory :question do
    content "MyText"
    survey_id { FactoryGirl.create(:survey).id }
    sequence(:order_number, 1000)

    trait :with_options do
      after(:create) do |question|
        create_list(:option, 5, :question => question)
      end
    end

    trait :mandatory do
      mandatory true
    end

    trait :private do
      private true
    end

    trait :finalized do
      finalized true
    end

    trait :identifier do
      identifier true
    end

    factory :question_with_answers do
      finalized true
      after(:create) do |question, evaluator|
        FactoryGirl.create_list(:answer, 5, :question => question)
      end
    end

    factory :question_with_options do
      after(:create) do |question, evaluator|
        question.type = 'RadioQuestion' if question.type.blank?
        FactoryGirl.create_list(:option, 5, :question => question)
        question.save!
      end
    end

    factory :question_with_image do
      after(:create) do |question, e|
        question.image = fixture_file_upload(Rails.root.to_s + '/spec/fixtures/images/sample.jpg', 'image/jpeg')
        question.save!
      end
    end

    factory :drop_down_question, :parent => :question, :class => DropDownQuestion do
      type 'DropDownQuestion'
    end

    factory :radio_question, :parent => :question, :class => RadioQuestion do
      type 'RadioQuestion'
    end

    factory :multi_choice_question, :parent => :question, :class => MultiChoiceQuestion do
      type 'MultiChoiceQuestion'
    end

    factory :photo_question, :parent => :question, :class => PhotoQuestion do
      type 'PhotoQuestion'
      image { fixture_file_upload(Rails.root.to_s + '/spec/fixtures/images/sample.jpg', 'image/jpeg') }
    end
  end
end
