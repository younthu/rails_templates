# refs: https://guides.rubyonrails.org/rails_application_templates.html
# https://multithreaded.stitchfix.com/blog/2014/01/06/rails-app-templates

def source_paths
    Array(super) +
      [File.join(File.expand_path(File.dirname(__FILE__)),'activeadmin_template/')]
end

# 替换source
puts "替换rubygems.org为http://mirros.aliyun.com/rubygems/"
comment_lines 'Gemfile', /rubygems.org/
insert_into_file 'Gemfile', "\nsource 'http://mirrors.aliyun.com/rubygems/'\n", after: "source 'https://rubygems.org'\n"

# 添加active_admin相关的gem
gems_str = <<-HEREDOC
# Active Admin
gem 'activeadmin'

# rails locale
gem 'rails-i18n'
# devise i18n
gem 'devise-i18n'

# Kaminari locale
gem "kaminari-i18n"

gem 'devise'
gem 'devise_token_auth', github: 'lynndylanhurley/devise_token_auth'

gem 'cancancan'
gem 'draper'
gem 'pundit'

# state machine
gem 'aasm'

# 微信支付
gem 'wx_pay'

# 微信登录, 小程序登录, app微信登录, 公众号管理
gem 'wechat'

# carrierwave
gem 'carrierwave', '~> 2.0'

# config loading from yml, can have private local.yml to overwrite public settings
# start from rails g config:install
gem 'config'

# global settings, based on ledermann/rails-settings, conflict with gem 'config', rails g settings:install will fail, https://github.com/younthu/rails_templates#%E9%97%AE%E9%A2%98%E8%A7%A3%E5%86%B3
# gem "rails-settings-cached", "~> 2.0"

# soft delete
gem "paranoia", "~> 2.2"

# puma killer
gem 'puma_worker_killer'

# 积分系统
gem 'merit'

# sidekiq
gem 'sidekiq'
HEREDOC
puts "添加active admin相关的gem\n#{gems_str}"
insert_into_file "Gemfile", gems_str,before: "\ngroup :development, :test do\n"

pry = <<-HEREDOC

    gem 'annotate' # auto annotate by run 'rails g annotate:install'
    # pry rails for dev console
    gem 'pry'
    gem 'pry-rails'

    # for rubymine debug unit test
    gem 'debase'

    # disable cors in development
    gem 'rack-cors'

    # profiler
    gem 'rack-mini-profiler'

    # rails panel, https://github.com/dejan/rails_panel
    gem 'meta_request'

    # Capistrano, app deployer
    gem "capistrano", require: false
    gem "capistrano-rails", require: false
    gem 'capistrano-rvm', require: false
    gem 'capistrano-passenger', require: false
    gem 'capistrano-bundler', require: false
    gem 'capistrano-maintenance', require: false
    gem 'capistrano-sidekiq'
    gem 'capistrano3-puma'
    gem 'capistrano-rake', require: false
HEREDOC

puts "添加pry相关的gem\n#{gems_str}"
insert_into_file "Gemfile", pry,after: "\ngroup :development do\n"

puts "pg gem"
pg = <<-HEREDOC
# Use postgresql as the database for Active Record
gem 'pg'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
HEREDOC

insert_into_file "Gemfile", pg, before: "\ngroup :development, :test do\n"
puts "中文本地化文件生成"
# loccale for zh-CN
inside "config/locales" do
    copy_file 'zh-CN.yml', 'zh-CN.yml' # FIXME: copy_file 'config/locales/zh-CN.yml' 不工作，说是找不到这个文件
end

# 设置默认locale为中文
puts "设置默认语言为zh-CN"
insert_into_file "config/application.rb", <<-EOF, after: "# the framework and any gems in your application."

    config.i18n.available_locales = [:en,:'zh-CN']
    config.i18n.default_locale = :'zh-CN'

EOF


# 设置默认locale为中文
puts "添加auto_load path for rotues/api.rb"
insert_into_file "config/application.rb", <<-EOF, after: "# the framework and any gems in your application."
        config.paths["config/routes.rb"].concat(Dir[Rails.root.join("config/routes/*.rb")])

EOF

# copy source list file from ali debian
puts "copy source list file"
copy_file "config/docker/ali_debian_buster.list", 'config/docker/ali_debian_buster.list'
# copy docker files
puts "copy docker files"
copy_file ".dockerignore", '.dockerignore'
copy_file "Dockerfile", "Dockerfile"
copy_file "docker-compose.yml", "docker-compose.yml"
copy_file "config/docker/docker-entrypoint.sh", "config/docker/docker-entrypoint.sh"
copy_file "config/docker/init.sql", "config/docker/init.sql"
copy_file "config/docker/ssh/sshkey.pub", "config/docker/ssh/sshkey.pub" # pub key for zhiyong mac
# copy_file "config/docker/ssh/root_key", "config/docker/ssh/root_key" # if File.file?("activeadmin_template/config/docker/ssh/root_key")# private key root_key and public key root_key.pub need to generate it manually by ssh-keygen
# copy_file "config/docker/ssh/root_key.pub", "config/docker/ssh/root_key.pub" # if File.file?("activeadmin_template/config/docker/ssh/root_key.pub") # private key root_key and public key root_key.pub need to generate it manually by ssh-keygen


# copy capistrano file
puts "copy capistrano files"
copy_file "Capfile", "Capfile"
copy_file "config/deploy.rb", "config/deploy.rb"
copy_file "config/deploy/local_docker.rb", "config/deploy/local_docker.rb"
copy_file "config/deploy/production.rb", "config/deploy/production.rb"
copy_file "config/deploy/staging.rb", "config/deploy/staging.rb"

# copy quick start
copy_file "../quick_start.md", "quick_start.md"

# copy devise token auth config file
copy_file "config/initializers/devise_token_auth.rb", "config/initializers/devise_token_auth.rb"
# config puma killer
pumakiller = <<-PUMA
# puma killer
before_fork do
  require 'puma_worker_killer'

  PumaWorkerKiller.enable_rolling_restart(6 * 3600) # Default is every 6 hours
end
PUMA

# 复制wechat相关的api文件
puts "复制wechat相关的api文件"
copy_file "app/controllers/api/base_controller.rb", "app/controllers/api/base_controller.rb" # api base controller
copy_file "app/controllers/api/login_by_codes_controller.rb", "app/controllers/api/login_by_codes_controller.rb"  # wechat小程序登录
copy_file "app/controllers/api/users/registrations_controller.rb", "app/controllers/api/users/registrations_controller.rb"
copy_file "app/controllers/api/users/sessions_controller.rb", "app/controllers/api/users/sessions_controller.rb"
copy_file "app/controllers/api/users/token_validations_controller.rb", "app/controllers/api/users/token_validations_controller.rb"
copy_file "config/routes/api.rb", "config/routes/api.rb"
append_to_file "config/puma.rb", pumakiller

# disable cors in development mode
disable_cors = <<-CORS

    # disable cors
    config.middleware.insert_before 0, Rack::Cors do
        allow do
            origins '*'
            resource '*', headers: :any, methods: [:get, :post, :put, :delete, :patch, :options]
        end
    end if defined? Rack::Cors

CORS
insert_into_file "config/application.rb", disable_cors, after: "# the framework and any gems in your application."

after_bundle do
    # git :init
    # git add: '.'
    # git commit: "-a -m 'Initial commit'"
  
    # disable yarn integrity check
    gsub_file 'config/webpacker.yml', 'check_yarn_integrity: true', 'check_yarn_integrity: false'

    # use redis in production
    gsub_file 'config/environments/production.rb', "# config.cache_store = :mem_cache_store", "config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }"
    
    # install webpacker
    rails_command 'webpacker:install'

    # install devise 
    generate "devise:install"

    # install active_admin
    generate "active_admin:install"

    # install annotate
    generate 'annotate:install'

    # generate kaminari config file
    generate 'kaminari:config'

puts <<-EOF

模板修改完毕！
接下来请运行:
1. rails g devise:install # done by template already
1.1 rails g devise:views <user># optional
1.2 rails g devise:controllers <user>
# 2. rails g active_admin:install
1. rails g config:install
1. rails g settings:install 
   or rails g settings:install SiteConfig
1. for soft delete you can run: rails g migration AddDeletedAtToCategories deleted_at:datetime:index
3. rake db:create && rake db:migrate && rake db:seed
4. rails admin通过admin@example.com, 'password' 登录
EOF
end

