class RecordsController < ApplicationController
  def create
    record = Record.new(params[:record])
    if record.save
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
