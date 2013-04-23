class DeepSurveySerializer < ActiveModel::Serializer
  attributes :id, :name, :expiry_date, :description, :published_on

  has_many :questions, :serializer => DeepQuestionSerializer
  has_many :categories, :serializer => DeepCategorySerializer
end