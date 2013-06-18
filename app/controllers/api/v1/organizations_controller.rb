module Api
  module V1
    class OrganizationsController < APIApplicationController
      def destroy
        authorize! :destroy, :organization
        organization = Organization.new(params[:id])
        organization.delay.destroy!
        render :nothing => true
      end
    end
  end
end
