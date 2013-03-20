class RecordsController < ApplicationController
  def create
    record = Record.create(params[:record])
    if record.valid?
      record.try(:category).create_blank_answers(params[:record].merge(:record_id => record.id))
      redirect_to :back
    else
      flash[:error] = record.errors.full_messages
      redirect_to :back
    end
  end

  def destroy
    record = Record.find(params[:id])
    record.destroy
    flash[:notice] = "Record Deleted"
    redirect_to :back
  end
end
