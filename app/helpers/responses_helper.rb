module ResponsesHelper
  def merge_arrays_using_attributes(first, second, attributes)
    (first + second).uniq do |object|
      attributes.map { |attribute|object.send(attribute) }
    end
  end
end