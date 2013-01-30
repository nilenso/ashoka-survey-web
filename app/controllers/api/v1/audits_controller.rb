module Api
  module V1
    class AuditsController < APIApplicationController

      def create
        filename = "#{Rails.root}/log/#{params[:device_id]}.log"
        file = File.new(filename, "a")
        file.puts params[:platform_data]
        file.puts params[:content]
        render :nothing => true
      end

      def update
        filename =  "#{Rails.root}/log/#{params[:id]}.log"
        file = File.open(filename, "a")
        file.puts params[:content]
        render :nothing => true
      end

    end
  end
end
