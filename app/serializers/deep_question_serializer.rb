class DeepQuestionSerializer < ActiveModel::Serializer
  attributes :id, :identifier, :parent_id, :min_value, :max_value, :type, :content,
              :survey_id, :max_length, :mandatory, :image_url, :order_number, :category_id
end