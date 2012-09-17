class Organization < ActiveRecord::Base
  attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :surveys

  def self.sync(organizations)
    organizations.each do |organization|
      unless exists?(organization['id'])
        org = Organization.new
        org.id = organization['id']
        org.name = organization['name']
        org.save
      end
    end
  end
end
