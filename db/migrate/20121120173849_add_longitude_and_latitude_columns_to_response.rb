class AddLongitudeAndLatitudeColumnsToResponse < ActiveRecord::Migration
  def change
  	add_column :responses, :latitude, :float
  	add_column :responses, :longitude, :float
  end
end
