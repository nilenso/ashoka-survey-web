module Api
  module V1
    class JobsController < APIApplicationController
      def alive
        job = Delayed::Job.find_by_id(params[:id])
        render :json => { alive: job.present? }
      end
    end
  end
end
