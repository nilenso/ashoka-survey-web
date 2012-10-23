class AddColumnStatusToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :status, :string, :default => "incomplete"
  end
end
