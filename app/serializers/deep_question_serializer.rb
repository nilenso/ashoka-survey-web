class DeepQuestionSerializer < ActiveModel::Serializer
  attributes :id, :identifier, :parent_id, :min_value, :max_value, :type, :content, :image_in_base64,
              :survey_id, :max_length, :mandatory, :image_url, :order_number, :category_id

  # Need to do this because `option` is a reserved name in this gem's NS.
  # http://stackoverflow.com/questions/15944179/issue-adding-has-many-to-activemodelserializer
  has_many :serializable_options, :key => :options, :serializer => DeepOptionSerializer

  def include_serializable_options?
    object.is_a? QuestionWithOptions
  end

  def serializable_options
    object.options.finalized
  end
end
