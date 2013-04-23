class DeepSurveySerializer < ActiveModel::Serializer
  attributes :id, :name, :expiry_date, :description, :finalized, :organization_id,
              :public, :auth_key, :published_on, :archived

  has_many :questions
  has_many :categories
end