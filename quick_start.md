# quick start development

1. docker build -t app .
2. docker-coompose up
3. 进入app container, bundle exec rails db:migrate

# production quick start
1. 改docker-compose.yml: db/volumes, 把数据库持久化到一个安全的目录
2. 改 web: environments, 把db, user name, password等改掉
3. 改 config/docker/init.sql, 创建production database
4. 
# Capistrano

# pitfalls

1. postgresql数据持久化的问题
2. debian terminal显示中文乱码的问题未解决。
3. devisetokenauth, 需要把每次请求都更换token的选项去掉
    ~~~
    #config/initializers/devise_token_auth.rb
     config.change_headers_on_each_request = false
    ~~~
4. 