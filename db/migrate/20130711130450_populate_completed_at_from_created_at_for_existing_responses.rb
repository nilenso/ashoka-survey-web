class PopulateCompletedAtFromCreatedAtForExistingResponses < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute("UPDATE responses SET completed_at = created_at;")
  end

  def down
    ActiveRecord::Base.connection.execute("UPDATE responses SET completed_at = NULL;")
  end
end
