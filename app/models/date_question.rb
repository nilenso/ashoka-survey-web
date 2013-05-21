# A question with a date type answer

class DateQuestion < Question
  def report_data
    answers_content = answers_for_reports.map(&:content)
    answers_content.uniq.inject([]) do |data, content|
      data.push [content, answers_content.count(content)]
    end
  end
end
