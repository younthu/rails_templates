# frozen_string_literal: true

class Api::LoginByCodesController < ::ApplicationController
  skip_before_action :verify_authenticity_token

  include ActionView::Rendering
  def render_to_body(options)
    _render_to_body_with_renderer(options) || super
  end

  def create
    code = params[:code]
    res = Wechat.api.web_access_token(code)
    openid = res['openid']
    unionid = res['unionid']
    access_token = res['access_token']
    # openid = "oiWo445A9vVeZ49dmdz5VhrccAjg"
    # session_key = "bHX0jIrSer0T5g0cYXpFoQ=="

    login_user = User.find_or_initialize_by(openid: openid)
    if(not login_user.persisted?)
      user_info = Wechat.api.web_userinfo(access_token, openid)
      # {"openid"=>"ogdA70kNhVQem0nOlwzGqvdWaUtM",
      #  "nickname"=>"北冥之鱼",
      #  "sex"=>2,
      #  "language"=>"zh_CN",
      #  "city"=>"",
      #  "province"=>"",
      #  "country"=>"卢森堡",
      #  "headimgurl"=>"http://thirdwx.qlogo.cn/mmopen/vi_32/X9TSedH6J3xwibibIsQeTcPAiaRy5ib9fhs4fze6mG4KCGZabnzu05wwlRPAf3RDXFm9keGp998aGrwyQfbh382ziaQ/132",
      #  "privilege"=>[],
      #  "unionid"=>"oVcvaw1RrgplBo0i-hJY7CUEsZcY"}
      Rails.logger.info user_info
      login_user.email = "#{openid}@wechat.com" unless login_user.email.present?
      login_user.openid = openid
      login_user.unionid = unionid
      login_user.avatar = user_info["headimgurl"]
      login_user.skip_password_validation = true
      login_user.name = user_info["nickname"]
      login_user.wechat_user_info = user_info
        # login_user.confirmed_at = Time.zone.now if login_user.new_record?
        login_user.save!
      login_user.invitation_code = login_user.gen_invitation_code # gen_invitation_code依赖于user.id, 所以需要save之后再计算.
      login_user.save!
    end

    user = login_user

    sign_in login_user

    # user_encoder = Warden::JWTAuth::UserEncoder.new
    # payload = user_encoder.helper.payload_for_user(login_user, "user")
    # payload["exp"] = Time.now.to_i + 1.year
    # payload["aud"] = 'tekapic'
    # jwt = Warden::JWTAuth::TokenEncoder.new.call(payload)
    # login_user.whitelisted_jwts.create(jti: payload["jti"], aud: payload["aud"], exp: Time.at(payload["exp"]))

    # render json: { openid: openid, jwt: jwt }, status: :ok
    if not user.board
      user.init_game_board
    else
      user.board.refresh_lucky_draw
    end


    render json: user, include: [:board], methods: [:auth_token, :financial_data] and return
    # render "show.json" and return
  end

  private

  def update_user_info
    # @user = current_user
    r = Wechat.decrypt(params[:encryptedData], @user.session_key, params[:iv])
    puts r
    @user.skip_password_validation = true
    @user.update(name:r["nickName"],nick_name: r["nickName"], gender: (r["gender"]=="1" or r["gender"]==1) ? "男": "女",
                 language: r["language"], city: r["city"], province: r["province"], country: r["country"],
                 avatar_url: r["avatarUrl"])
  end

  def user_info_params

    params.require(:detail).permit(:errMsg, :rawData,
                                   :signature, :encryptedData, :iv,
                                   userInfo: [:nickName, :gender, :language, :city, :province, :country, :avatarUrl])
  end

end
