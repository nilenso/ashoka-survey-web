class AddADefaultValueForStateInResponses < ActiveRecord::Migration
  def up
    change_column :responses, :state, :string, :default => 'clean'
    responses = Response.where(:state => nil)
    responses.each do |response|
      response.update_column :state, "clean"
    end
  end

  def down
    change_column :responses, :state, :string, :default => nil
  end
end
