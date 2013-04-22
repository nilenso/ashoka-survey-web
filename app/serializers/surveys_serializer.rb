class SurveysSerializer
  def initialize(surveys)
    @surveys = surveys
  end

  def as_json(options={})
    if options[:with_sub_elements]
      @surveys.joins(:questions).as_json(:include => :questions)
    else
      @surveys.as_json
    end
  end
end