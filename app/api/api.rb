class API < Grape::API

  def self.inherited(subclass)
    super
    subclass.instance_eval do
      helpers API::CurrentUser
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

    end
  end

  module CurrentUser
    def current_user
      @current_user ||= User.authorize_user!(params[:device_token])
    end

    def authenticate!
      error!('401 Unauthorized', 401) unless current_user
    end
  end

  mount Users::APIV1
  mount Posts::APIV1
end
