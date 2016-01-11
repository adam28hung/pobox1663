FactoryGirl.define do
  factory :user do
    sequence(:device_token) { |n| "token#{n}"}
    sequence(:nickname) { |n| "chicago #{n}"}
    os "ios"
    version "9.1.0"
    avatar Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/images/avatar.jpg", "image/jpg")

    trait :with_post do
      after(:create) do |user|
        user.posts << create(:post)
      end
    end

  end
end
