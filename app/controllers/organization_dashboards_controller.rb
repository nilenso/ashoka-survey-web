class OrganizationDashboardsController < ApplicationController
  authorize_resource :class => false

  def index
    @organizations = OrganizationDecorator.decorate(Organization.all(access_token), :context => { :access_token => access_token })
  end
end
