Rails.application.routes.draw do
  mount V1::Checkin => '/'
end
