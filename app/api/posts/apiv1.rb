module Posts
  class APIV1 < API
    version 'v1', using: :path

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

      desc "get user post"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :id, type: Integer, desc: "Post id"
      end
      get ':id'  do
        authenticate!
        user_post = current_user.posts.where(id: params['id']).first
      end

      desc "create user post"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :post, type: Hash do
          requires :message, type: String, desc: "message"
          requires :site_name, type: String, desc: "site_name"
          requires :lat, type: Float, values: -90.0..+90.0, desc: 'Current latitude.'
          requires :lng, type: Float, values: -180.0..+180.0, desc: 'Current longitude.'
        end
      end
      post ''  do
        authenticate!
        current_user.posts << Post.create!(params['post'])
      end

      desc "update user post"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :id, type: Integer, desc: "Post id"
        requires :post, type: Hash do
          optional :message, type: String, desc: "message"
          optional :site_name, type: String, desc: "site_name"
          optional :lat, type: Float, values: -90.0..+90.0, desc: 'Current latitude.'
          optional :lng, type: Float, values: -180.0..+180.0, desc: 'Current longitude.'
        end
      end
      patch ':id'  do
        authenticate!
        user_post = current_user.posts.where(id: params['id']).first
        user_post.update_attributes(params['post'])
      end

      desc "delete user post"
      params do
        requires :device_token, type: String, desc: "device token"
        requires :id, type: Integer, desc: "Post id"
      end
      delete ':id'  do
        authenticate!
        user_post = current_user.posts.where(id: params['id']).first
        user_post.destroy
      end

    end

  end
end
