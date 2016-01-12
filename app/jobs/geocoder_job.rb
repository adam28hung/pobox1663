class GeocoderJob < ActiveJob::Base
  include Geokit::Geocoders
  queue_as :default

  def perform(post)
    res=Geokit::Geocoders::GoogleGeocoder.reverse_geocode "#{post.lat},#{post.lng}", language: 'zh-tw'
    post.address = res.full_address
    post.save
  end
end
