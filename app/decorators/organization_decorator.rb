class OrganizationDecorator < Draper::Base
  def survey_count
    Survey.where(:organization_id => model.id).count
  end

  def survey_count_in_words
    h.pluralize(survey_count, "Survey")
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
    responses.count(:group => "to_char(created_at, 'YYYY/MM')").to_a.sort_by(&:first).map { |date, count| [Date.parse(date).strftime("%b %Y"), count] }
  end

  def responses_per_month_graph
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Month')
    data_table.new_column('number', 'Responses')
    data_table.add_rows(response_count_grouped_by_month)
    option = { chartArea: { width: '40%', left: '5%' }, legend: { position: 'bottom' }, title: 'Number of Responses', height: 600, isStacked: true, series: [ { color: '#cd8322' }, { color: '#4d5a6b'} ] }
    GoogleVisualr::Interactive::ColumnChart.new(data_table, option)
  end

  private

  def responses
    Response.where(:survey_id => Survey.where(:organization_id => model.id), :blank => false)
  end
end
