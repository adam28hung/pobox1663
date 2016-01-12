module Users
  class APIV1 < API
    version 'v1', using: :path

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

  end
end
