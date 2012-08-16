namespace :db do
  desc "Populate DB with Fake Data"
  task fake: :environment do
    1000.times do
      Survey.create(
        :name => Forgery(:name).full_name,
        :expiry_date => 28.days.from_now,
        :description => Forgery(:basic).text
        )
    end
  end
end
