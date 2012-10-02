class Sanitizer
  def self.clean_params(params)
    return [] if params.nil?
    params.reject { |key| key.blank? }
  end
end
