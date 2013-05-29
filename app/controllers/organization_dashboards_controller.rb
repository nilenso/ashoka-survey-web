class OrganizationDashboardsController < ApplicationController
  authorize_resource :class => false

  def index
    @decorated_organizations = OrganizationDecorator.decorate_collection(Organization.all(access_token), :context => { :access_token => access_token })
  end

  def show
    organization = Organization.find_by_id(access_token, params[:id])
    if organization
      @decorated_organization = organization.decorate(:context => { :access_token => access_token })
    else
      render :nothing => true, :status => :not_found
    end
  end
end
