module Api
  module Mobile
    module V1
      class SurveysController < ApplicationController
        def index
          render :json => Survey.all.map(&:name)
        end
      end
    end
  end
end
