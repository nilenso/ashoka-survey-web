ActiveSupport.on_load(:active_model_serializers) do
  ActiveModel::ArraySerializer.root = false
  ActiveModel::Serializer.root = false
end