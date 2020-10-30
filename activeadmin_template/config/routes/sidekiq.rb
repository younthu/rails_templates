require 'sidekiq/web'

Rails.application.routes.draw do
    unless Rails.env.development?
        Sidekiq::Web.use Rack::Auth::Basic do |username, password|
        username == Rails.application.secrets.sidekiq[:username] && password == Rails.application.secrets.sidekiq[:password]
        end
    end
    mount Sidekiq::Web => '/sidekiq'
end