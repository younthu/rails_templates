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
gem 'cancancan'
gem 'draper'
gem 'pundit'

# state machine
gem 'aasm'

# carrierwave
gem 'carrierwave', '~> 2.0'

# config loading from yml, can have private local.yml to overwrite public settings
gem 'config'

# global settings, based on ledermann/rails-settings, conflict with gem 'config', rails g settings:install will fail
# gem "rails-settings-cached", "~> 2.0"

# soft delete
gem "paranoia", "~> 2.2"

# puma killer
gem 'puma_worker_killer'

HEREDOC
puts "添加active admin相关的gem\n#{gems_str}"
insert_into_file "Gemfile", gems_str,before: "\ngroup :development, :test do\n"

pry = <<-HEREDOC

    # pry rails for dev console
    gem 'pry'
    gem 'pry-rails'

    # disable cors in development
    gem 'rack-cors'

    # profiler
    gem 'rack-mini-profiler'

    # rails panel, https://github.com/dejan/rails_panel
    gem 'meta_request'

    # Capistrano, app deployer
    gem "capistrano", "~> 3.11", require: false
    gem "capistrano-rails", "~> 1.3", require: false
    gem 'capistrano-rvm', require: false
    gem 'capistrano-passenger', require: false
    gem 'capistrano-bundler', '~> 1.1.2', require: false
    gem 'capistrano-maintenance', '~> 1.0', require: false
    gem 'capistrano-sidekiq'
    gem 'capistrano3-puma'
    gem 'capistrano-rake', require: false
HEREDOC

puts "添加pry相关的gem\n#{gems_str}"
insert_into_file "Gemfile", pry,after: "\ngroup :development do\n"

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

# copy docker files
puts "copy docker files"
copy_file ".dockerignore", '.dockerignore'
copy_file "Dockerfile", "Dockerfile"
copy_file "Docker-compose.yml", "Docker-compose.yml"
copy_file "config/docker/docker-entrypoint.sh", "config/docker/docker-entrypoint.sh"
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

# config puma killer
pumakiller = <<-PUMA
# puma killer
before_fork do
  require 'puma_worker_killer'

  PumaWorkerKiller.enable_rolling_restart(6 * 3600) # Default is every 6 hours
end
PUMA

append_to_file "config/puma.rb", pumakiller

# disable cors in development mode
disable_cors = <<-CORS
    # disable cors
    config.middleware.insert_before 0, Rack::Cors do
        allow do
            origins '*'
            resource '*', headers: :any, methods: [:get, :post, :put, :delete, :patch, :options]
        end
    end if Rails.env.development?

CORS
insert_into_file "config/application.rb", disable_cors, after: "# the framework and any gems in your application."

after_bundle do
    # git :init
    # git add: '.'
    # git commit: "-a -m 'Initial commit'"
  
    # disable yarn integrity check
    gsub_file 'config/webpacker.yml', 'check_yarn_integrity: true', 'check_yarn_integrity: false'
    
    # install devise 
    generate "devise:install"

    # install active_admin
    # generate "active_admin:install"

puts <<-EOF

模板修改完毕！
接下来请运行:
1. rails g devise:install # done by template already
1.1 rails g devise:views <user># optional
1.2 rails g devise:controllers <user>
2. rails g active_admin:install
1. rails g config:install
1. rails g settings:install 
   or rails g settings:install SiteConfig
1. for soft delete you can run: rails g migration AddDeletedAtToCategories deleted_at:datetime:index
3. rake db:create && rake db:migrate && rake db:seed
4. rails admin通过admin@example.com, 'password' 登录
EOF
end

