require 'rails_helper'

RSpec.describe V1::Checkin, type: :request do

  describe "check user is authorized" do
    it ".authorize_user!" do
      user = FactoryGirl.create(:user)
      expect(User.authorize_user!(user.device_token)).to eq(user)
      expect(User.authorize_user!('UNREGISTTOKEN')).to eq(nil)
    end
  end

  describe "User endpoints" do
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

    describe "POST /api/v1/users/:device_token/follow/:id" do

      it "can follow other user" do
        user1 = FactoryGirl.create(:user, device_token: 'USERTOKEN1', nickname: 'user1')
        user2 = FactoryGirl.create(:user, device_token: 'USERTOKEN2', nickname: 'user2')

        post "/api/v1/users/#{user1.device_token}/follow/#{user2.id}"
        expect(response.status).to eq(201)
        expect(response.body).to eq("Followed".to_json)
      end

      it "can't follow a invalid user" do
        user1 = FactoryGirl.create(:user, device_token: 'USERTOKEN1', nickname: 'user1')

        post "/api/v1/users/#{user1.device_token}/follow/#{user1.id.to_i-1}"
        expect(response.body).to eq("Can't follow this user".to_json)
      end

    end

    describe "DELETE /api/v1/users/:device_token/unfollow/:id" do

      it "can unfollow other user" do
        user1 = FactoryGirl.create(:user, device_token: 'USERTOKEN1', nickname: 'user1')
        user2 = FactoryGirl.create(:user, device_token: 'USERTOKEN2', nickname: 'user2')
        user1.follow(user2)

        delete "/api/v1/users/#{user1.device_token}/unfollow/#{user2.id}"
        expect(response.status).to eq(200)
        expect(response.body).to eq("Unfollowed".to_json)
      end

      it "can unfollow a invalid user" do
        user1 = FactoryGirl.create(:user, device_token: 'USERTOKEN1', nickname: 'user1')

        delete "/api/v1/users/#{user1.device_token}/unfollow/#{user1.id-1}"
        expect(response.body).to eq("Can't unfollow this user".to_json)
      end

    end

    describe "GET /api/v1/users/:device_token/fans" do

      it "can list user's fans" do
        user1 = FactoryGirl.create(:user, device_token: 'USERTOKEN1', nickname: 'user1')
        user2 = FactoryGirl.create(:user, device_token: 'USERTOKEN2', nickname: 'user2')
        user3 = FactoryGirl.create(:user, device_token: 'USERTOKEN3', nickname: 'user3')
        user1.follow(user3)
        user2.follow(user3)

        get "/api/v1/users/#{user3.device_token}/fans"
        expect(response.status).to eq(200)
        expect(response.body).to eq([user1, user2].to_json)
      end

    end

    describe "GET /api/v1/users/:device_token/followed_users" do
      it "can list user's followed_users" do
        user1 = FactoryGirl.create(:user, device_token: 'USERTOKEN1', nickname: 'user1')
        user2 = FactoryGirl.create(:user, device_token: 'USERTOKEN2', nickname: 'user2')
        user1.follow(user2)

        get "/api/v1/users/#{user1.device_token}/followed_users"
        expect(response.status).to eq(200)
        expect(response.body).to eq([user2].to_json)
      end
    end

  end

  describe "Post endpoints" do

    describe "GET /api/v1/users/:device_token/posts" do
      it "list user's posts" do
        user1 = FactoryGirl.create(:user, :with_post)

        get "/api/v1/users/#{user1.device_token}/posts"
        expect(response.status).to eq(200)
        expect(response.body).to eq(user1.posts.to_json)
      end
    end

    describe "GET /api/v1/posts/nearby" do
      context "can list nearby check-in records(posts) base on user location" do
        it "has posts nearby" do
          user1 = FactoryGirl.create(:user, :with_post)
          params = {lat: 25.0333646, lng: 121.5637253, device_token: user1.device_token}

          get "/api/v1/posts/nearby", params
          expect(response.status).to eq(200)
          expect(response.body).to eq(user1.posts.to_json)
        end

        it "has no posts nearby" do
          user1 = FactoryGirl.create(:user, :with_post)
          # somewhere in Okinawa
          params = {lat:26.2728826, lng:127.6944762, device_token: user1.device_token}

          get "/api/v1/posts/nearby", params
          expect(response.status).to eq(200)
          expect(response.body).to eq([].to_json)
        end
      end
    end

    describe "GET /api/v1/posts/inradius" do
      context "can list nearby check-in records(posts) base on user location" do

        it "has posts nearby in range 1km" do
          user1 = FactoryGirl.create(:user)
          Post.create({message: '逛夜市', site_name:'六合夜市' \
                       , lat:22.6320758, lng:120.296966, user_id: user1.id})
          expect_response = Post.create({message: '逛大街' \
                                         , site_name:'統一阪急百貨' \
                                         , lat:25.0371655, lng:121.5596045 \
                                         , user_id: user1.id})


          params = { lat: 25.0333646, lng: 121.5637253 \
                     , device_token: user1.device_token, radius: 1}

          get "/api/v1/posts/inradius", params
          expect(response.status).to eq(200)
          expect(response.body).to eq([expect_response].to_json)
        end

        it "has posts nearby in range 5km" do
          user1 = FactoryGirl.create(:user)
          Post.create({message: '逛夜市', site_name:'六合夜市' \
                       , lat:22.6320758, lng:120.296966, user_id: user1.id})
          expect_response = Post.create([{message: '逛大街' \
                                          , site_name:'統一阪急百貨' \
                                          , lat:25.0371655, lng:121.5596045 \
                                          , user_id: user1.id} \
                                         ,{message: '吃咖哩', site_name:'寅樂屋咖啡咖哩小食堂' \
                                           , lat:25.0371655, lng:121.5596045, user_id: user1.id}])
          params = { lat: 25.0333646, lng: 121.5637253 \
                     , device_token: user1.device_token, radius: 5}

          get "/api/v1/posts/inradius", params
          expect(response.status).to eq(200)
          expect(response.body).to eq(expect_response.to_json)
        end

        it "has posts nearby in range 10km" do
          user1 = FactoryGirl.create(:user)
          Post.create({message: '逛夜市', site_name:'六合夜市' \
                       , lat:22.6320758, lng:120.296966, user_id: user1.id})
          expect_response = Post.create([{message: '逛大街' \
                                          , site_name:'統一阪急百貨' \
                                          , lat:25.0371655, lng:121.5596045 \
                                          , user_id: user1.id} \
                                         ,{message: '逛夜市', site_name:'樂華夜市' \
                                           , lat:25.008584, lng:121.5117573, user_id: user1.id}])
          params = { lat: 25.0333646, lng: 121.5637253 \
                     , device_token: user1.device_token, radius: 10}

          get "/api/v1/posts/inradius", params
          expect(response.status).to eq(200)
          expect(response.body).to eq(expect_response.to_json)
        end

        it "has no posts nearby" do
          user1 = FactoryGirl.create(:user)
          Post.create({message: '逛夜市', site_name:'六合夜市' \
                       , lat:22.6320758, lng:120.296966, user_id: user1.id})
          params = { lat: 25.0333646, lng: 121.5637253 \
                     , device_token: user1.device_token, radius: 10}

          get "/api/v1/posts/inradius", params
          expect(response.status).to eq(200)
          expect(response.body).to eq([].to_json)
        end

      end
    end

    describe "GET /api/v1/posts/:id" do
      it "create user posts" do
        user1 = FactoryGirl.create(:user, :with_post)
        user1_post_id = user1.posts.first.id
        Post.create({message: '逛夜市', site_name:'六合夜市' \
                     , lat:22.6320758, lng:120.296966, user_id: user1.id})
        params = { device_token: user1.device_token \
                   , post: { id: user1_post_id } }

        get "/api/v1/posts/#{user1_post_id}", params
        expect(response.status).to eq(200)
        expect(response.body).to eq(user1.posts.first.to_json)
      end
    end

    describe "POST /api/v1/posts" do
      it "create user posts" do
        user1 = FactoryGirl.create(:user)
        params = { device_token: user1.device_token \
                   , post: {message: '逛夜市', site_name:'逢甲夜市' \
                            , lat:24.795929, lng:120.6444043, user_id: user1.id } }
        post "/api/v1/posts", params
        expect(response.status).to eq(201)
        expect(response.body).to eq(user1.posts.to_json)
      end
    end

    describe "PATCH /api/v1/posts/:id" do
      it "update user posts" do
        user1 = FactoryGirl.create(:user, :with_post)
        user1_post_id = user1.posts.first.id
        params = { device_token: user1.device_token \
                   , post: {id: user1_post_id, message: '吃晚餐' } }

        patch "/api/v1/posts/#{user1_post_id}", params
        expect(response.status).to eq(200)
        expect(user1.posts.first.message).to eq('吃晚餐')
      end
    end

    describe "DELETE /api/v1/posts/:id" do
      it "delete user posts" do
        user1 = FactoryGirl.create(:user, :with_post)
        user1_post_id = user1.posts.first.id
        expect_response = Post.create({message: '逛夜市', site_name:'六合夜市' \
                                       , lat:22.6320758, lng:120.296966, user_id: user1.id})
        params = { device_token: user1.device_token \
                   , post: { id: user1_post_id } }

        delete "/api/v1/posts/#{user1_post_id}", params
        expect(response.status).to eq(200)
        expect(user1.posts.count).to eq(1)
        expect(user1.posts.first.message).to eq('逛夜市')
      end
    end

  end

end
