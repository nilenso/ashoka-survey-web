require 'will_paginate/array'

class SurveysController < ApplicationController
  load_and_authorize_resource

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
    survey.delay(:queue => 'survey_duplication').duplicate(:organization_id => current_user_org)
    redirect_to surveys_path(:filter => "drafts"), :notice => t("surveys.duplicate.duplication_in_progress")
  end

  def report
    @survey = SurveyDecorator.find(params[:id])
    responses = Response.accessible_by(current_ability)
    @complete_responses_count = responses.where(:status => 'complete').count
    @markers = @survey.responses.where(:status => "complete").to_gmaps4rails
  end

  private

  def require_draft_survey
    survey = Survey.find(params[:survey_id])
    if survey.finalized?
      flash[:error] = t "flash.edit_finalized_survey"
      redirect_to root_path
    end
  end
end
