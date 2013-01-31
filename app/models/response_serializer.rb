class ResponseSerializer
  attr_reader :response

  def initialize(response)
    @response = response
  end


  def to_json_with_answers_and_choices
   response.to_json(:include => {:answers => {:include => :choices, :methods => :photo_in_base64}})
  end

  def render_json(update = nil)
    response.complete if response_validating?
    response.destroy if update.nil? && response.invalid?
    to_json_with_answers_and_choices
  end

  private 

  def response_validating?
    response.valid? && response.validating?
  end
end
