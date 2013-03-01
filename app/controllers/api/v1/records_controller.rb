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
end
