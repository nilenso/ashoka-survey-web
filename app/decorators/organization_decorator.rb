class OrganizationDecorator < Draper::Decorator
  delegate_all

  def survey_count
    surveys.count
  end

  def survey_count_in_words
    h.pluralize(survey_count, "Survey")
  end

  def asset_space_in_bytes
    question_space = Question.where("photo_file_size IS NOT NULL AND survey_id IN (?)", surveys).sum("photo_file_size")
    answer_space = Answer.where("photo_file_size IS NOT NULL AND response_id IN (?)", responses).sum("photo_file_size")
    question_space + answer_space
  end

  def asset_space_in_words
    h.number_to_human_size(asset_space_in_bytes)
  end

  def response_count
    responses.count
  end

  def response_count_in_words
    h.pluralize(response_count, "Response")
  end

  def user_count
    Organization.users(context[:access_token], model.id).count
  end

  def user_count_in_words
    h.pluralize(user_count, "User")
  end

  def response_count_grouped_by_month
    responses.count(:group => "to_char(created_at, 'Mon YYYY')").to_a.sort_by { |date_in_words,_| Date.parse(date_in_words) }
  end

  def survey_count_grouped_by_month
    surveys.count(:group => "to_char(created_at, 'Mon YYYY')").to_a.sort_by { |date_in_words,_| Date.parse(date_in_words) }
  end

  def responses_per_month_graph
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Month')
    data_table.new_column('number', 'Responses')
    data_table.add_rows(response_count_grouped_by_month)
    options = {
      legend: { position: 'bottom' },
      title: 'Number of Responses Created per Month',
      height: 600,
      series: [{ color: '#cd8322' }]
    }
    GoogleVisualr::Interactive::ColumnChart.new(data_table, options)
  end

  def surveys_per_month_graph
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Month')
    data_table.new_column('number', 'Surveys')
    data_table.add_rows(survey_count_grouped_by_month)
    options = {
      legend: { position: 'bottom' },
      title: 'Number of Surveys Created per Month',
      height: 600,
      series: [{ color: '#4d5a6b'}]
    }
    GoogleVisualr::Interactive::ColumnChart.new(data_table, options)
  end

  private

  def responses
    Response.where(:survey_id => Survey.where(:organization_id => model.id), :answers_present => true)
  end

  def surveys
    Survey.where(:organization_id => model.id)
  end
end
