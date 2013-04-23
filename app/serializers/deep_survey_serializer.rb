class DeepSurveySerializer < ActiveModel::Serializer
  attributes :id, :name, :expiry_date, :description, :published_on

  has_many :questions
  has_many :categories
end