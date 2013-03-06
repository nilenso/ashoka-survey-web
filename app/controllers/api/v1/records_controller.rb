class Api::V1::RecordsController < ApplicationController
  respond_to :json

  def create
    record = Record.create(params[:record])
    if record.valid?
      render :json => record
    else
      render :json => record.errors, :status => :bad_request
    end
  end

  def update
    record = Record.find_by_id(params[:id])
    if record.nil?
      render :nothing => true, :status => :gone
    else
      render :json => record
    end
  end
end
