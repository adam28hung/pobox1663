class Post < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :message, :site_name, :lat, :lng

end
