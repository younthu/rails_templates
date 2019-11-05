# rails_templates
rails templates

## 使用

~~~shell
rails new your_app -m <path_to_template/activeadmin_template.rb>
rails new your_app -m http://example.com/template.rb
~~~

或者用下面的命令去修改一个已经存在的app

~~~sh
rails app:template LOCATION=http://example.com/template.rb
~~~

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

# 参考
1. [rails app template](https://multithreaded.stitchfix.com/blog/2014/01/06/rails-app-templates/)
2. [Rails Application Templates](https://guides.rubyonrails.org/rails_application_templates.html)