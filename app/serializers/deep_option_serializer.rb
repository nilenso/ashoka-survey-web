class DeepOptionSerializer < ActiveModel::Serializer
  attributes :id, :order_number, :content, :question_id
end