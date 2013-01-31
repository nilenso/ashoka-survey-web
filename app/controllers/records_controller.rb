class RecordsController < ApplicationController
  def create
    record = Record.create(params[:record])
    if record.valid?
      redirect_to :back
    else
      flash[:error] = record.errors.full_messages
      redirect_to :back
    end
  end
end
