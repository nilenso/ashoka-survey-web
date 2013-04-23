class DeepCategorySerializer < ActiveModel::Serializer
  attributes :id, :parent_id, :type, :content, :survey_id, :order_number, :category_id
end