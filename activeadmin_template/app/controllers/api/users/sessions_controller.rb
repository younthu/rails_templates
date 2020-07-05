# frozen_string_literal: true
module Api
  module Users
    class SessionsController < ::DeviseTokenAuth::SessionsController
      skip_before_action :verify_authenticity_token
      include DeviseTokenAuth::Concerns::SetUserByToken
      # include Devise::Controllers::Rememberable
      # before_action :configure_sign_in_params, only: [:create]
      # layout "jquery_mobile"

      # GET /resource/sign_in
      def new
        super
        # render "login"
      end

      # POST /resource/sign_in
      def create
        # super # 默认的super没法在scope User下工作，只在AdminUser下工作，所以User下手动sign_in, 手动remember_me
        mobile = params[:mobile]
        password = params[:password]
        user = nil
        user = User.find_by(mobile: mobile) if mobile
        user = User.find_by(email: params[:email]) unless mobile

        if not user
          render json: "用户不存在", status: 404 and return
        end

        if user&.valid_password? password
          sign_in :user, user
          set_user_by_token

          session[:current_user_id] = user.id

          if not user.board
            user.init_game_board
          else
            user.board.refresh_lucky_draw
          end

          render json: user, include: [:board], methods: [:auth_token, :financial_data] and return
        end
        render json: "用户名密码不对!", status: 401
      end

      # DELETE /resource/sign_out
      # def destroy
      #   super
      # end

      # protected

      # If you have extra params to permit, append them to the sanitizer.
      # def configure_sign_in_params
      #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
      # end
    end
  end
end
