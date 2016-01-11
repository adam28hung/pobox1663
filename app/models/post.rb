class Post < ActiveRecord::Base
  include Geokit::Geocoders
  belongs_to :user

  acts_as_mappable :default_units => :kms

  validates_presence_of :message, :site_name, :lat, :lng

end
