require 'rails_helper'

RSpec.describe Posts::APIV1, type: :request do
  include ActiveJob::TestHelper

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
        params = { device_token: user1.device_token }

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
        expect(response.body).to eq(user1.posts.last.to_json)

        clear_enqueued_jobs
        clear_performed_jobs
      end
    end

    describe "PATCH /api/v1/posts/:id" do
      it "update user posts" do
        user1 = FactoryGirl.create(:user, :with_post)
        user1_post_id = user1.posts.first.id
        params = { device_token: user1.device_token \
                   , post: { message: '吃晚餐' } }

        patch "/api/v1/posts/#{user1_post_id}", params
        expect(response.status).to eq(200)
        expect(user1.posts.first.message).to eq('吃晚餐')

        clear_enqueued_jobs
        clear_performed_jobs
      end
    end

    describe "DELETE /api/v1/posts/:id" do
      it "delete user posts" do
        user1 = FactoryGirl.create(:user, :with_post)
        user1_post_id = user1.posts.first.id
        expect_response = Post.create({message: '逛夜市', site_name:'六合夜市' \
                                       , lat:22.6320758, lng:120.296966, user_id: user1.id})
        params = { device_token: user1.device_token }

        delete "/api/v1/posts/#{user1_post_id}", params
        expect(response.status).to eq(200)
        expect(user1.posts.count).to eq(1)
        expect(user1.posts.first.message).to eq('逛夜市')
      end
    end

  end

end
