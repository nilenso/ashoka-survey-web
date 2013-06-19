namespace :db do
  desc "Set up coverage config in enviroment"
  task :remove_deleted_organizations_data => :environment do
    Organization.deleted_organizations.each do |organization|
      puts "Deleting data for organization ##{organization.id}"
      organization.destroy!
    end
  end
end
