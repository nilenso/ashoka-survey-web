require 'will_paginate/array'

class SurveysController < ApplicationController
  before_filter :require_cso_admin, :except => [:index, :build]
  before_filter :survey_unpublished, :only => [:build]
  def index
    if !user_currently_logged_in?
      @surveys = []
      #temporary fix for 'public' surveys
    else
      @surveys = Survey.find_all_by_organization_id(session[:user_info][:org_id])
      if session[:user_info][:role] == 'cso_admin'
        @surveys.select! { |s| s.published.to_s == params[:published] } if params[:published] != nil
      elsif session[:user_info][:role] == 'user'
        @surveys.select! { |s| s.users.include?(session[:user_id]) }
      end
    end
    @surveys = @surveys.paginate(:page => params[:page], :per_page => 10)
  end

  def destroy
    survey = Survey.find(params[:id])
    survey.destroy
    flash[:notice] = t "flash.survey_deleted"
    redirect_to(surveys_path)
  end

  def new
    @survey = Survey.new()
  end

  def create
    @survey = Survey.new(params[:survey])
    @survey.organization_id = session[:user_info][:org_id]

    if @survey.save
      flash[:notice] = t "flash.survey_created"
      redirect_to surveys_build_path(:id => @survey.id)
    else
      render :new
    end
  end

  def build
    @survey = Survey.find(params[:id])
  end

  def publish
    @survey = Survey.find(params[:survey_id])
    @users = access_token.get('api/organization_users').parsed
  end


  def publish_to_users
    survey = Survey.find(params[:survey_id])
    survey.publish
    params[:survey][:users].delete_if { |s| s.blank? }
    params[:survey][:users].each do |user|
      SurveyUser.create(:survey_id => survey.id, :user_id => user)
    end
    flash[:notice] = t "flash.survey_published", :survey_name => survey.name
    redirect_to(surveys_path)
  end

  def share
    @survey = Survey.find(params[:survey_id])
    if @survey.published?
      @organizations = access_token.get('api/organizations').parsed
      @organizations.select!{ |org| org["id"] != @survey.organization_id }
    else
      redirect_to surveys_path
      flash[:error] = "Can not share an unpublished survey"
    end
  end

  def update_shared_orgs
    survey = Survey.find(params[:survey_id])
    params[:survey][:participating_organization_ids].each do |org_id|
      ParticipatingOrganization.find_or_create(:survey_id => survey.id, :organization_id => org_id)
    end
    survey.save
    flash[:notice] = "Successfully shared..."
    redirect_to surveys_path
  end

  private

  def require_cso_admin
    role = session[:user_info][:role] if user_currently_logged_in?
    unless role == 'cso_admin'
      flash[:error] = t "flash.not_authorized"
      redirect_to surveys_path
    end
  end

  def survey_unpublished
    survey = Survey.find(params[:id])
    if survey.published?
      flash[:error] = t "flash.edit_published_survey"
      redirect_to root_path
    end
  end
end
