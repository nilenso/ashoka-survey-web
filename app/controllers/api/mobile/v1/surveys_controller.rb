module Api
  module Mobile
    module V1
      class SurveysController < ApplicationController
        def index
          render :json => Survey.select("id, name, description, expiry_date")
        end

        def show
          survey = Survey.find(params[:id])
          render :json => survey.questions.select("id, content")
        end
      end
    end
  end
end
