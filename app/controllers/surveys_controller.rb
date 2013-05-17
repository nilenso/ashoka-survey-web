require 'will_paginate/array'

class SurveysController < ApplicationController
  load_and_authorize_resource
  before_filter :redirect_to_https, :only => :index

  def index
    @surveys ||= Survey.none
    filtered_surveys = SurveyFilter.new(@surveys, params[:filter]).filter
    paginated_surveys = filtered_surveys.paginate(:page => params[:page], :per_page => 10)
    @surveys = SurveyDecorator.decorate(paginated_surveys)
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
    redirect_to survey_build_path(:survey_id => @survey.id)
  end

  def build
    @survey = SurveyDecorator.find(params[:survey_id])
  end

  def finalize
    survey = Survey.find(params[:survey_id])
    survey.finalize
    flash[:notice] = t "flash.survey_finalized", :survey_name => survey.name
    redirect_to edit_survey_publication_path(survey.id)
  end

  def archive
    survey = Survey.find(params[:survey_id])
    if survey.archive
      flash[:notice] = t("flash.survey_archived", :survey_name => survey.name)
    else
      flash[:error] = survey.errors.messages
    end
    redirect_to root_path
  end

  def duplicate
    survey = Survey.find(params[:id])
    if survey.duplicate(:organization_id => current_user_org).save(:validate => false)
      redirect_to :back, :notice => t('surveys.duplicate.survey_duplicated')
    else
      redirect_to :back, :error => t('surveys.duplicate.duplication_error')
    end
  end

  def report
    @survey = SurveyDecorator.find(params[:id])
    responses = Response.accessible_by(current_ability)
    @complete_responses_count = responses.where(:status => 'complete').count
    @markers = @survey.responses.where(:status => "complete").to_gmaps4rails
  end

  private

  def redirect_to_https
    # Need request.head? because mobile makes a HEAD request to this same path and Titanium
    # since doesn't follow redirects, we can't redirect to https:// in that case.
    redirect_to :protocol => "https://" if !request.ssl? && !request.head?
  end
end
