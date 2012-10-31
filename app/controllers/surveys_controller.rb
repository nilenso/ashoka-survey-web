require 'will_paginate/array'

class SurveysController < ApplicationController
  load_and_authorize_resource

  before_filter :require_unpublished_survey, :only => [:build]
  before_filter :require_published_survey, :only => [:share_with_organizations]
  before_filter :require_organizations_to_be_selected, :only => [:update_share_with_organizations]

  def index
    @surveys ||= []
    @surveys = @surveys.where(:published => true)  if params[:published].present?
    @surveys = @surveys.where(:published => false) if params[:unpublished].present?
    @surveys = @surveys.paginate(:page => params[:page], :per_page => 5)
    @surveys = SurveyDecorator.decorate(@surveys)
    @organizations = Organization.all(access_token)
  end

  def destroy
    survey = Survey.find(params[:id])
    survey.destroy
    flash[:notice] = t "flash.survey_deleted"
    redirect_to(surveys_path)
  end

  def create
    @survey = Survey.new(params[:survey])
    @survey.organization_id = current_user_org

    @survey.name ||= I18n.t('js.untitled_survey')
    @survey.expiry_date ||= 5.days.from_now
    @survey.description ||= "Description goes here"

    @survey.save
    flash[:notice] = t "flash.survey_created"
    redirect_to surveys_build_path(:id => @survey.id)
  end

  def build
    @survey = SurveyDecorator.find(params[:id])
  end

  def publish_to_users
    @survey = Survey.find(params[:survey_id])
    users = Organization.users(access_token, current_user_org).reject { |user| user.id == current_user }
    @shared_users = @survey.users_for_organization(access_token, current_user_org)
    @unshared_users = users.reject { |user| @shared_users.map(&:id).include?(user.id) }
  end

  def update_publish_to_users
    survey = Survey.find(params[:survey_id])
    users = Sanitizer.clean_params(params[:survey][:user_ids])
    if users.present?
      survey.publish_to_users(users)
      survey.publish
      flash[:notice] = t "flash.survey_published", :survey_name => survey.name
      redirect_to surveys_path
    else
      flash[:error] = t "flash.user_not_selected"
      redirect_to(:back)
    end
  end

  def share_with_organizations
    @survey = Survey.find(params[:survey_id])
    organizations = Organization.all(access_token, :except => @survey.organization_id)
    @shared_organizations, @unshared_organizations = organizations.partition do |organization|
      @survey.participating_organization_ids.include? organization.id
    end
  end

  def update_share_with_organizations
    survey = Survey.find(params[:survey_id])
    organizations = Sanitizer.clean_params(params[:survey][:participating_organization_ids])
    survey.share_with_organizations(organizations)
    flash[:notice] = t "flash.survey_shared", :survey_name => survey.name
    redirect_to surveys_path
  end

  def duplicate
    survey = Survey.find(params[:id])
    if survey.duplicate.save
      redirect_to :back, :notice => t('surveys.duplicate.survey_duplicated')
    else
      redirect_to :back, :error => t('surveys.duplicate.duplication_error')
    end
  end

  def report
    @survey = SurveyDecorator.find(params[:id])
  end

  private

  def require_organizations_to_be_selected
    organizations = Sanitizer.clean_params(params[:survey][:participating_organization_ids])
    if organizations.blank?
      flash[:error] = t "flash.organizations_not_selected"
      redirect_to(:back)
    end
  end

  def require_unpublished_survey
    survey = Survey.find(params[:id])
    if survey.published?
      flash[:error] = t "flash.edit_published_survey"
      redirect_to root_path
    end
  end

  def require_published_survey
    survey = Survey.find(params[:survey_id])
    unless survey.published?
      redirect_to surveys_path
      flash[:error] = t "flash.sharing_unpublished_survey"
    end
  end
end
