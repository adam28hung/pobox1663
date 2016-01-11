require 'rails_helper'

RSpec.describe V1::Checkin, type: :request do

  describe "POST /v1/users/regist" do
    it "creates user if token hadn't been taken" do
      user_detail = { device_token: 'ANEWTOKEN', nickname: 'test user' \
                      , os: 'ios', version: '9.0' }
      post "/api/v1/users/regist", user_detail
      expect(response.status).to eq(201)
    end

    it "return 403 if token already been taken" do
      user = FactoryGirl.create(:user)
      user.device_token = "ALREADYTAKEN"
      user.save
      # same token as user
      user_detail = { device_token: 'ALREADYTAKEN', nickname: 'test user' \
                      , os: 'ios', version: '9.0' }
      post "/api/v1/users/regist", user_detail
      expect(response.status).to eq(403)
    end
  end

  describe "PATCH /v1/users/:device_token/upload_avatar" do
    it "updates user avatar" do
      user = FactoryGirl.create(:user)
      user.device_token = "REGISTTOKEN"
      user.avatar = nil
      user.save
      avatar = fixture_file_upload("#{Rails.root}/spec/fixtures/images/avatar.jpg", 'image/jpg')
      patch "/api/v1/users/REGISTTOKEN/upload_avatar", avatar: avatar
      expect(response.status).to eq(200)
    end
  end

  describe "GET /v1/users/:device_token" do

    it ".authorize_user!" do
      user = FactoryGirl.create(:user)
      expect(User.authorize_user!(user.device_token)).to eq(user)
    end

    it "returns user info if user is registed" do
      user = FactoryGirl.create(:user)
      user.device_token = "REGISTTOKEN"
      user.save
      expected_response = user.to_json

      get "/api/v1/users/REGISTTOKEN"
      expect(response.status).to eq(200)
      expect(response.body).to eq(expected_response)
    end

    it "won't return user info if user not regist before" do
      get "/api/v1/users/UNREGISTTOKEN"
      expect(response.status).to eq(401)
    end
  end

end
