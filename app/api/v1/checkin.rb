module V1
  class Checkin < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    rescue_from ActiveRecord::RecordInvalid do |e|
      record = e.record
      message = e.message.downcase.capitalize
      Rack::Response.new(
        [{ status: 403, status_code: "record_invalid", error: message }.to_json],
        403,
        { 'Content-Type' => 'application/json' }
      )
    end

    helpers do
      def current_user
        @current_user ||= User.authorize_user!(params[:device_token])
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :users do

      desc "Regist a user"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :nickname, type: String, desc: "nickname"
        requires :os, type: String, desc: "os name"
        requires :version, type: String, desc: "os version"
      end
      post '/regist'  do
        user = User.create!(params)
      end

      desc "update user avatar"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :avatar, type: Rack::Multipart::UploadedFile, desc: 'Image to upload.'
      end
      patch ':device_token/upload_avatar'  do
        authenticate!
        current_user.avatar =  params[:avatar][:tempfile]
        current_user.save
        current_user
      end

      desc "Get user info"
      params do
        requires :device_token, type: String, desc: "device token"
      end
      get ':device_token'  do
        authenticate!
        current_user
      end

      desc "Follow a user"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :id, type: Integer, desc: "other user id"
      end
      post ':device_token/follow/:id'  do
        authenticate!
        other_user = User.where(id: params[:id]).first
        if other_user.present?
          current_user.follow(other_user)
          "Followed"
        else
          "Can't follow this user"
        end
      end

      desc "Unfollow a user"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :id, type: Integer, desc: "other user id"
      end
      delete ':device_token/unfollow/:id'  do
        authenticate!
        other_user = User.where(id: params[:id]).first
        if other_user.present?
          current_user.unfollow(other_user)
          "Unfollowed"
        else
          "Can't unfollow this user"
        end
      end

      desc "List fans"
      params do
        requires :device_token, type: String, desc: "device token"
      end
      get ':device_token/fans'  do
        authenticate!
        current_user.fans
      end

      desc "List followed_users"
      params do
        requires :device_token, type: String, desc: "device token"
      end
      get ':device_token/followed_users'  do
        authenticate!
        current_user.followed_users
      end

      desc "List user's posts"
      params do
        requires :device_token, type: String, desc: "device token"
      end
      get ':device_token/posts'  do
        authenticate!
        current_user.posts
      end

    end

    resource :posts do
      desc "List nearby posts base on user location by default range=0.5km"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :lat, type: Float, values: -90.0..+90.0, desc: 'Current latitude.'
        requires :lng, type: Float, values: -180.0..+180.0, desc: 'Current longitude.'
      end
      get '/nearby'  do
        authenticate!
        Post.within( 0.5, origin: "#{params[:lat]},#{params[:lng]}")
      end

      desc "List nearby posts base on user location by given radius"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :lat, type: Float, values: -90.0..+90.0, desc: 'Current latitude.'
        requires :lng, type: Float, values: -180.0..+180.0, desc: 'Current longitude.'
        requires :radius, type: Float, default: 0.5, values: [0.5, 1.0, 5.0, 10.0], desc: 'Radius in Kms.'
      end
      get '/inradius'  do
        authenticate!
        Post.within( params[:radius].to_i, origin: "#{params[:lat]},#{params[:lng]}")
      end

    end

  end
end
