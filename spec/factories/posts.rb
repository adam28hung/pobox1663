FactoryGirl.define do
  factory :post do
    sequence(:message) { |n| "看風景#{DateTime.now}"}
    site_name "101觀景台"
    lat 25.0333646
    lng 121.5637253
    address ""
    user nil
  end
end
