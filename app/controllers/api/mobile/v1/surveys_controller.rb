module Api
  module Mobile
    module V1
      class SurveysController < ApplicationController
        def index
          render :json => Survey.select("id, name, description, expiry_date")
        end
      end
    end
  end
end
