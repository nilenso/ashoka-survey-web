class AddColumnBlankToResponses < ActiveRecord::Migration
  def up
    add_column :responses, :blank, :boolean

    Response.reset_column_information
    Response.where(:blank => nil).each do |response|
      response.update_column :blank, false
    end
  end

  def down
    remove_column :responses, :blank
  end
end
