# rails_templates
这是一个rails模板，在rails默认基础上加一些gem和配置, 也包含docker配置文件.


## 使用

1. 在activeadmin_template/config/docker/ssh下生成ssh key: root_key和root_key.pub
2. 用rails命令生成rails项目模板
   
~~~shell
rails new your_app -m <path_to_template/activeadmin_template.rb>
docker build . # 编译docker文件
~~~

或者用下面的命令去修改一个已经存在的app

~~~sh
rails app:template LOCATION=https://raw.githubusercontent.com/younthu/rails_templates/master/activeadmin_template.rb # 需要翻墙
~~~

运行完毕以后可以进行后续安装:

1. rails g devise:install
  1. rails g devise:views <user># optional
  2. rails g devise:controllers <user>
2. rails g active_admin:install
3. rails g config:install
4. rails g settings:install 
   or rails g settings:install SiteConfig
5. for soft delete you can run: rails g migration AddDeletedAtToCategories deleted_at:datetime:index
6. rake db:create && rake db:migrate && rake db:seed
7. rails admin通过admin@example.com, 'password' 登录

## 数据库初始化
docker-compose 会加载config/docker/init.sql, 完成app_development database的初始化.

如果是production环境，
1. 需要自己手动创建数据, 或者修改init.sql来生成对应的数据库.
1. 同时，需要修改docker-compose.yml, 修改数据库名称和用户名密码等参数.
2. 还要修改 docker-compose.yml下的db/volumes, 把数据库持久化到另外一个目录下面去，别放代码目录下，很危险。
  ~~~yml
      volumes:
      - /var/www/db/postgres:/var/lib/postgresql/data
      # all scripts in /docker-entrypoint-initdb.d/ will be executed while start at the first time
      - ./config/docker/init.sql:/docker-entrypoint-initdb.d/init.sql
  ~~~
3. 

## 定制内容
1. 替换source为aliyun source
2. 拷贝本地化文件config/locales/zh-CN.yml, 需要汉化的话改这个文件就可以了。
3. 设置默认locale为zh-CN
4. 添加active admin相关的gem包
5. 添加i18n包。
6. Dockerfile, rails 2.6.3
7. Docker-compose.yml
8. development模式下disable cors
9. miniprofiler for development
10. gem config
11. soft delete
12. puma killer

## Next

1. 通过`rails_command`运行`bundle install`, 然后做后期自动化安装.
2. 
### 运行docker 

  1. 编译Dockerfile: `docker build -t webapp .`
  2. `docker run -d --name webapp -v $PWD:/var/www -p 3000:3000 webapp` 
## 问题解决
1. yarn integrity check failed.  解决办法: 把yarn.lock删除.
2. gem 'config' 和 gem 'rails-settings-cached' 冲突. 解决办法, 修改config/initializers/config.rb
   ~~~
   config.const_name = 'StaticSettings'
   ~~~

# RoadMap
1. 写一份readme, 拷贝到模板项目里面去，让用户可以通过readme解决很多细节问题。比如devise接下来怎么做，capistrano怎么做。
2. 
# 参考
1. [rails app template](https://multithreaded.stitchfix.com/blog/2014/01/06/rails-app-templates/)
2. [Rails Application Templates](https://guides.rubyonrails.org/rails_application_templates.html)
3. [Rails Template](https://github.com/mattbrictson/rails-template)