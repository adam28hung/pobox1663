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

    end

  end
end
