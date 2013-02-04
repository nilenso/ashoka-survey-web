class ResponseSerializer
  attr_reader :response

  def initialize(response)
    @response = response
  end

  def to_json_with_answers_and_choices
   response.to_json(:include => {:answers => {:include => :choices, :methods => :photo_in_base64}})
  end

  def render_json(update = nil)
    response.complete
    response.destroy_if_invalid unless update
    to_json_with_answers_and_choices
  end
end
