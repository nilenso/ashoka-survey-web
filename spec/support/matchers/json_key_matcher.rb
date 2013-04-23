RSpec::Matchers.define :have_json_key do |key|
  match do |serializer|    
    serializer.as_json.has_key? key
  end
end