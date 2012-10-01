class Sanitizer
  def self.clean_params(params)
    params.reject { |key| key.blank? }
  end
end
