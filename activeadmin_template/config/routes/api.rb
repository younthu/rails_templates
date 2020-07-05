Rails.application.routes.draw do
    devise_for :admin_users, ActiveAdmin::Devise.config
    devise_for :users, controllers: { sessions: 'users/sessions' }

    namespace :api do
        scope :v1 do
            mount_devise_token_auth_for 'User', at: 'users', controllers: {
                token_validations:  'api/users/token_validations',
                sessions: 'api/users/sessions'
            }

            resource :login_by_code, only: %i[create] # 微信小程序登录api
        end
    end
end