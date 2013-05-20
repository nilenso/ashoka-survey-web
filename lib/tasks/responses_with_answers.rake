namespace :db do
  desc "Populate DB with Fake Data"
  task fake_responses: :environment do
    def answer_for(question, answer_obj)
      type = question.type
      case type
      when 'SingleLineQuestion'
        (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
      when 'MultilineQuestion'
        str = ""
        (0..20).to_a.shuffle.first.times do
          str << (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
          str << " "
        end
        str
      when 'DateQuestion'
        rand(1..5).days.ago.strftime("%Y/%m/%d")
      when 'RatingQuestion'
        (0..5).to_a.shuffle.first
      when 'NumericQuestion'
        (0..10).to_a.shuffle.first
      when 'RadioQuestion'
        question.options.shuffle.first.content
      when 'DropDownQuestion'
        question.options.shuffle.first.content
      when 'MultiChoiceQuestion'
        options = question.options
        how_many = (1..options.size).to_a.shuffle.first
        selected_options = options.shuffle.first(how_many)
        for option in selected_options
          FactoryGirl.create :choice, :answer_id => answer_obj.id, :option_id => option.id
        end
        selected_options.map(&:content).join(", ")
      else
        ""
      end
    end

    def get message
      print message
      STDIN.gets.chomp
    end

    id = get("Enter the ID of the Survey you want to add responses for: ")
    number = get("How many responses do you want to add? ")
    survey = Survey.find_by_id(id.to_i)
    number.to_i.times do |i|
      questions = survey.questions.where(:finalized => true)

      r = Response.new
      r.survey = survey
      r.organization_id = survey.organization_id
      r.user_id = rand(1..10)
      r.save

      for question in questions
        answer = Answer.new
        answer.response_id = r.id
        answer.question_id = question.id
        answer.content = answer_for(question, answer)
        p answer.errors unless answer.save
      end

      r.latitude = rand(-45.000000000...45.000000000)
      r.longitude = rand(-90.000000000...90.000000000)
      r.save
      r.complete
    end
  end
end
